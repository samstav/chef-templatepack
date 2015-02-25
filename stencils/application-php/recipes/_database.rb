#
# Cookbook Name:: |{ cookbook['name'] }|
# Recipe :: |{ options['name'] }|
#
# Copyright |{ cookbook['year'] }|, Rackspace
#

mysql_listen_address = '127.0.0.1'
if !node['rackspace'].nil? && !node['rackspace']['private_ip'].nil? && !Chef::Config[:solo]
  mysql_listen_address = node['rackspace']['private_ip']
end

app_name = |{ qstring(options['name']) }|

app_secrets = {}
begin
  app_secrets = Chef::EncryptedDataBagItem.load('secrets', app_name)
rescue
  Chef::Log.warn('No encrypted data bag found! Using default values')
  app_secrets['deploy_key'] = nil
  app_secrets['db'] = {}
  app_secrets['db']['name'] = 'CHANGE_ME'
  app_secrets['db']['user'] = 'CHANGE_ME_AS_WELL'
  app_secrets['db']['pass'] = 'FOR_SURE_CHANGE_ME'
end

template "/root/#{app_name}.sql" do
  source "sites/#{app_name}/setup.sql.erb"
  owner 'root'
  group 'root'
  mode '0600'
  variables(
    db_user: app_secrets['db']['user'],
    db_pass: app_secrets['db']['pass'],
    db_name: app_secrets['db']['name'],
    local_mysql: mysql_listen_address
  )
  notifies :run, "execute[SQL_constants_for_#{app_name}]", :delayed
end
execute "SQL_constants_for_#{app_name}" do
  command "mysql -uroot -p'#{node['mysql']['server_root_password']}' < /root/#{app_name}.sql"
  ignore_failure true
end
