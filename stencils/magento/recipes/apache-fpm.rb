# Encoding: utf-8
#
# Cookbook Name:: magentostack
# Recipe:: apache
#
# Copyright 2014, Rackspace Hosting
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'chef-sugar'

# see recipes/mod_ssl.rb in apache2 for why this is coded this way
ports = [node['|{.Cookbook.Name}|']['web']['http_port'], node['|{.Cookbook.Name}|']['web']['https_port']]
ports.each do |p|
  unless node['apache']['listen_ports'].include?(p)
    node.set['apache']['listen_ports'] =  node['apache']['listen_ports'] + [p]
  end
end

# Modules dependencies (Magento/Php-fpm)
apache_modules = %w(
  status actions alias auth_basic
  authn_file authz_default
  authz_groupfile authz_host
  authz_user autoindex dir env mime
  negotiation setenvif ssl headers
  expires
)

# repo dependencies for php-fpm
if platform_family?('rhel')
  include_recipe 'yum'
  include_recipe 'yum-epel'
  include_recipe 'yum-ius'
  # manually installed modules for rhel only
  apache_modules.concat %w( log_config logio)
elsif platform_family?('debian')
  include_recipe 'apt'
  if ubuntu_precise?
    # force php 5.5 on Ubuntu < 14.04
    # using http://ppa rather than ppa: to be sure it passes firewall
    apt_repository 'php5-5' do
      uri          'http://ppa.launchpad.net/ondrej/php5/ubuntu'
      keyserver    'hkp://keyserver.ubuntu.com:80'
      key          '14AA40EC0831756756D7F66C4F4EA0AAE5267A6C'
      components   ['main']
      distribution node['lsb']['codename']
    end
    # however we don't want apache from ondrej/php5
    apt_preference 'apache' do
      glob         '*apache*'
      pin          'release o=Ubuntu'
      pin_priority '600'
    end
  end
end

node.default['apache']['default_modules'] = apache_modules

# install php libraries requirements
php_version = node['|{.Cookbook.Name}|']['php']['version']
node['|{.Cookbook.Name}|']["#{php_version}"]['packages'].each do |phplib|
  package phplib
end
node.set['php-fpm']['package_name'] = node['php-fpm']["package_name-#{php_version}"]

# enable mcrypt module on Ubuntu 14
# https://bugs.launchpad.net/ubuntu/+source/php-mcrypt/+bug/1243568
execute 'enable mcrypt module' do
  command 'php5enmod mcrypt'
  creates '/etc/php5/cli/conf.d/20-mcrypt.ini'
  action :run
  only_if { ubuntu_trusty? }
end

%w(
  apache2
  apache2::mod_fastcgi
  php-fpm
).each do |recipe|
  include_recipe recipe
end

# create self signed certificate (enable by default)
openssl_x509 node['|{.Cookbook.Name}|']['web']['ssl_cert'] do
  common_name node.name
  org 'Magento'
  org_unit 'Magento'
  country 'US'
  key_file node['|{.Cookbook.Name}|']['web']['ssl_key']
  only_if { node['|{.Cookbook.Name}|']['web']['ssl_autosigned'] }
end

# Fast-cgi configuration
apache_conf 'fastcgi' do
  enable true
end

# Create documentroot
directory node['|{.Cookbook.Name}|']['web']['dir'] do
  action :create
  not_if { File.exist?(node['|{.Cookbook.Name}|']['web']['dir']) }
end

# Create vhost
%w(default ssl).each do |site|
  web_app site do
    template node['|{.Cookbook.Name}|']['web']['template']
    cookbook node['|{.Cookbook.Name}|']['web']['cookbook']
    http_port node['|{.Cookbook.Name}|']['web']['http_port']
    docroot node['|{.Cookbook.Name}|']['web']['dir']
    server_name node['|{.Cookbook.Name}|']['web']['domain']
    server_aliases node['|{.Cookbook.Name}|']['web']['server_aliases']
    ssl true if site == 'ssl'
    https_port node['|{.Cookbook.Name}|']['web']['https_port']
    ssl_cert node['|{.Cookbook.Name}|']['web']['ssl_cert']
    ssl_key node['|{.Cookbook.Name}|']['web']['ssl_key']
  end
end

# Open ports for Apache
include_recipe 'platformstack::iptables'
add_iptables_rule('INPUT', "-m tcp -p tcp --dport #{node['|{.Cookbook.Name}|']['web']['http_port']} -j ACCEPT", 100, 'Allow access to apache')
add_iptables_rule('INPUT', "-m tcp -p tcp --dport #{node['|{.Cookbook.Name}|']['web']['https_port']} -j ACCEPT", 100, 'Allow access to apache')

# required by stack_commons::mysql_base to find the app nodes (mysql user permission)
tag('magento_app_node')

# set http_port and domain variables in in the recipe as they are built from attributes
node.default['platformstack']['cloud_monitoring']['custom_monitors']['custom_http']['variables']['http_port'] = node['|{.Cookbook.Name}|']['web']['http_port']
node.default['platformstack']['cloud_monitoring']['custom_monitors']['custom_http']['variables']['domain'] = node['|{.Cookbook.Name}|']['web']['domain']
node.default['platformstack']['cloud_monitoring']['custom_monitors']['custom_http']['variables']['host'] = node.deep_fetch('cloud', 'public_ipv4') || node['ipaddress']
include_recipe 'platformstack::monitors' if node.deep_fetch('platformstack', 'cloud_monitoring', 'enabled')
