# Encoding: utf-8
#
# Cookbook Name:: |{.Cookbook.Name}|
# Recipe:: magento_configure
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

http_port = node['|{.Cookbook.Name}|']['web']['http_port']
url = if http_port == 80
        "http://#{node['|{.Cookbook.Name}|']['web']['domain']}/"
      else
        "http://#{node['|{.Cookbook.Name}|']['web']['domain']}:#{http_port}/"
      end
node.default['|{.Cookbook.Name}|']['config']['url'] = url

https_port = node['|{.Cookbook.Name}|']['web']['https_port']
secure_base_url = if https_port == 443
                    "https://#{node['|{.Cookbook.Name}|']['web']['domain']}/"
                  else
                    "https://#{node['|{.Cookbook.Name}|']['web']['domain']}:#{https_port}/"
                  end
node.default['|{.Cookbook.Name}|']['config']['secure_base_url'] = secure_base_url

# Run install.php script for initial magento setup
# We must be sure we know all important configuration to pass to magento at this point

# Configure all the database things
include_recipe '|{.Cookbook.Name}|::_find_mysql'
database_name = node['|{.Cookbook.Name}|']['mysql']['databases'].keys[0]
dbh = node['|{.Cookbook.Name}|']['config']['db']['host']
dbp = node['|{.Cookbook.Name}|']['config']['db']['port']
database_host = if dbh && dbp
                  "#{dbh}:#{dbp}"
                elsif dbh
                  dbh
                else
                  false
                end
database_user = node['|{.Cookbook.Name}|']['mysql']['databases'][database_name]['mysql_user']
database_pass = node['|{.Cookbook.Name}|']['mysql']['databases'][database_name]['mysql_password']

# temporary location for script that runs install.php
setup_script = "#{Chef::Config[:file_cache_path]}/magento.sh"

# output of install.php goes into this file, needs to be writeable by apache
# but ensure it stays outside of the actual web-accessible dir ('docroot/magento')
magento_configured_file = "#{node['|{.Cookbook.Name}|']['web']['dir']}/.magento_configured"

template setup_script do
  source 'magento.sh.erb'
  user node['apache']['user']
  group node['apache']['group']
  mode '0700'
  variables(
  db_name: database_name,
  db_host: database_host,
  db_user: database_user,
  db_pass: database_pass,
  magento_configured_file: magento_configured_file
  )
end

cookbook_file "#{node['|{.Cookbook.Name}|']['web']['dir']}/check-magento-installed.php" do
  source 'check-magento-installed.php'
  user node['apache']['user']
  group node['apache']['group']
  mode '0700'
end

execute setup_script do
  cwd node['|{.Cookbook.Name}|']['web']['dir']
  user node['apache']['user']
  group node['apache']['group']
  not_if { File.exist?(magento_configured_file) }
end

include_recipe '|{.Cookbook.Name}|::_magento_redis'
