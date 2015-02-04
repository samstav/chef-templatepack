#
# Cookbook Name:: |{.Cookbook.Name}|
# Recipe :: |{.Options.Name}|
#
# Copyright |{ .Cookbook.Year }|, Rackspace
#

# Add the 5.6 repo
apt_repository 'php5.6' do
  uri 'ppa:ondrej/php5-5.6'
  distribution node['lsb']['codename']
end

# Install php5.6
package 'python-software-properties'
php5_packages = %w(
  php5
  php5-intl
  php5-fpm
  php5-mysql
  php5-gd
  php5-curl
  php5-redis
  php5-memcached
  php5-memcache
  php5-imagick)
php5_packages.each do |pkg|
  package pkg do
    options '--force-yes'
    options '-o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"'
    action [:upgrade, :install]
  end
end

# Configure OP cache template
template '/etc/php5/mods-available/opcache.ini' do
  source 'php/05_opcache.ini.erb'
  cookbook cookbook_name
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[php5-fpm]'
end

# PHP FPM pool
template '/etc/php5/fpm/pool.d/www.conf' do
  source 'php/pool.conf.erb'
  cookbook cookbook_name
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[php5-fpm]'
end

# PHP.ini
template '/etc/php5/fpm/php.ini' do
  source 'php/php.ini.erb'
  cookbook cookbook_name
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    redis_local: "#{node['address_map']['my_ip']}:#{node['address_map']['redis_port']}",
    memory_limit: 128
  )
  notifies :restart, 'service[php5-fpm]'
end
template '/etc/php5/cli/php.ini' do
  source 'php/php.ini.erb'
  cookbook cookbook_name
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    redis_local: "#{node['address_map']['my_ip']}:#{node['address_map']['redis_port']}",
    memory_limit: 1024
  )
end

# PHP-FPM configuration
template '/etc/php5/fpm/php-fpm.conf' do
  source 'php/php-fpm.conf.erb'
  cookbook cookbook_name
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[php5-fpm]'
end

# Ensure PHP-FPM is running
service 'php5-fpm' do
  service_name 'php5-fpm'
  provider Chef::Provider::Service::Upstart
  supports restart: true, status: true
  action [:enable, :start]
end
