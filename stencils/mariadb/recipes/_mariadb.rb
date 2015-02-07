#
# Cookbook Name:: |{ .Cookbook.Name }|
# Recipe :: |{ .Options.Name }|
#
# Copyright |{ .Cookbook.Year }|, Rackspace
#
# The MySQL galera server recipe, which runs MariaDB 10.0

%w(debconf-utils percona-xtrabackup rsync).each do |pkg|
  package pkg do
    action :install
  end
end

# Tune MySQL automagically
open_files_limit = 8192

# Consider using "rackspace_networks" stencil for easy networking magic :)
if node['address_map'].nil?
  # Use servicenet by default - NOT RECOMMENED - flip to false and make use of a cloud network
  # see "rackspace_networks" for more.
  node.default['address_map'] = {}
  node.default['address_map']['use_service_net'] = true
  iface = 'eth1'
  node.default['address_map']['service_net_iface'] = iface
  mysql_listen_address = node['network']['interfaces'][iface]['addresses'].find do |addr, addr_info|
    addr_info[:family] == 'inet'
  end
  mysql_listen_address = mysql_listen_address.first
else
  mysql_listen_address = node['address_map']['my_ip']
end

# Default to assuming our server is a 1gb slice
system_total_mem_mb = '1024'
unless node['memory']['total'].nil?
  system_total_mem_mb = (node['memory']['total'].gsub(/kB/, '').to_i / 1024).round
end

# The service is now totally installed and configured - time to configure the cluster
node.default['mariadb']['debian']['user'] = 'root'
node.default['mariadb']['debian']['password'] = node['mysql']['server_root_password']
node.default['mariadb']['debian']['host'] = mysql_listen_address

# Preseed MySQL installation with paswords, etc.
begin
  resources(directory: '/var/cache/local/preseeding')
rescue Chef::Exceptions::ResourceNotFound
  directory '/var/cache/local/preseeding' do
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
  end
end
template '/var/cache/local/preseeding/mariadb-galera-server.seed' do
  source 'mariadb/server-seed.erb'
  owner 'root'
  group 'root'
  mode '0600'
  variables(package_name: 'mariadb-galera-server')
  notifies :run, 'execute[preseed mariadb-galera-server]', :immediately
end
execute 'preseed mariadb-galera-server' do
  command '/usr/bin/debconf-set-selections /var/cache/local/preseeding/mariadb-galera-server.seed'
  action :nothing
end

# Add the MariaDB 10 repo
apt_repository 'mariadb' do
  uri 'http://ftp.osuosl.org/pub/mariadb/repo/10.0/ubuntu'
  distribution node['lsb']['codename']
  components ['main']
  # Force use of port 80 for keyserver transaction
  # this bypasses issues with strict firewalls on testing machines
  keyserver 'hkp://keyserver.ubuntu.com:80'
  key '0xcbcb082a1bb943db'
end

# Install mariadb server!
package 'mariadb-galera-server' do
  action [:upgrade, :install]
end

# MySQL ulimit setting
user_ulimit 'mysql' do
  filehandle_limit open_files_limit
  core_hard_limit 'unlimited'
end

# Allow passwordless logins for admins
template '/root/.my.cnf' do
  source 'mariadb/.my.cnf.erb'
  owner 'root'
  group 'root'
  mode '0600'
  variables(
    pass: node['mysql']['server_root_password']
  )
end

# Galera clustering search
galera_options = {}
gcomm = ''
unless Chef::Config[:solo]
  first = true
  db_galera_raw = search(:node, "tags:*galera_node* AND chef_environment:#{node.chef_environment}")
  if !db_galera_raw.nil? && !db_galera_raw.empty? && !db_galera_raw.first.nil?
    db_galera_raw.each do |raw_node|
      next if raw_node.name == node.name
      # If we're using servicenet, find other nodes servicenet addresses
      if node['address_map']['use_service_net']
        iface = node['address_map']['service_net_iface']
        best_ip = raw_node['network']['interfaces'][iface]['addresses'].find do |addr, addr_info|
          addr_info[:family] == 'inet'
        end
        best_ip = best_ip.first
      else
        # Alternatively, if you're using rackspace cloud networks, find those addresses instead
        privatenet = raw_node['rackspace']['private_networks'].find do |network|
          network['label'] == node.chef_environment
        end
        best_ip = privatenet['ips'].first['ip']
      end
      next if best_ip.nil?
      gcomm += ',' unless first
      gcomm += best_ip
      first = false
    end
  end
end

galera_options['wsrep_cluster_address'] = gcomm
galera_options['wsrep_cluster_name'] = "galera_cluster_#{node.chef_environment}"
galera_options['wsrep_sst_method'] = 'rsync'

template '/etc/mysql/my.cnf' do
  source 'mariadb/my.cnf.erb'
  owner 'root'
  group 'root'
  mode '0600'
  variables(
    listen: mysql_listen_address,
    server_id: mysql_listen_address.gsub(/\./, ''),
    open_files_limit: 65_535,
    table_open_cache: (open_files_limit / 4).round,
    # innodb_buffer_pool_size will be 50% of the systems total memory
    innodb_buffer_pool_size: (system_total_mem_mb / 3).round,
    innodb_log_file_size: (system_total_mem_mb / 32).round,
    innodb_log_buffer_size: (system_total_mem_mb / 32).round,
    # MariaDB does not need a very large connection pool - particularly when paired with PHP 5.6
    # which is quite good at closing connections - we'll allow 15 connections per GB of memory for now
    # which is fairly arbitrary, but makes an OK baseline
    max_connections: ((system_total_mem_mb / 1024).round + 1) * 15,
    tmp_table_size: (system_total_mem_mb / 32).round,
    query_cache_size: (system_total_mem_mb / 32).round,
    galera_options: galera_options
  )
  notifies :restart, 'service[mysql]'
end

# Ensure service is runing
service 'mysql' do
  service_name 'mysql'
  supports restart: true, status: true
  action [:enable, :start]
  retries 1
  retry_delay 3
  # notifies :create, 'template[/root/constants.sql]', :immediate
end

execute 'correct-debian-grants' do
  command 'mysql -r -B -N -e "GRANT SELECT, INSERT, UPDATE, DELETE, ' + \
    'CREATE, DROP, RELOAD, SHUTDOWN, PROCESS, FILE, REFERENCES, INDEX, ' + \
    'ALTER, SHOW DATABASES, SUPER, CREATE TEMPORARY TABLES, ' + \
    'LOCK TABLES, EXECUTE, REPLICATION SLAVE, REPLICATION CLIENT, ' + \
    'CREATE VIEW, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, ' + \
    "CREATE USER, EVENT, TRIGGER ON *.* TO '" + \
    node['mariadb']['debian']['user'] + \
    "'@'" + node['mariadb']['debian']['host'] + "' IDENTIFIED BY '" + \
    node['mariadb']['debian']['password'] + "' WITH GRANT OPTION\""
  action :run
  only_if do
    cmd = Mixlib::ShellOut.new("/usr/bin/mysql --user=\"" + \
      node['mariadb']['debian']['user'] + \
      "\" --password=\"" + node['mariadb']['debian']['password'] + \
      "\" -r -B -N -e \"SELECT 1\"")
    cmd.run_command
    cmd.error?
  end
  ignore_failure true
end

tag('mysql_master')
tag('galera_node')
