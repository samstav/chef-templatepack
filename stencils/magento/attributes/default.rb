# Encoding: utf-8
#
# Cookbook Name:: |{.Cookbook.Name}|
# Recipe:: default
#
# Copyright 2014, Rackspace UK, Ltd.
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

# ensure these run at compile
default['build-essential']['compile_time'] = true
default['xml']['compiletime'] = true

# Stack_commons configuration attributes
# should not be changed
default['stack_commons']['stackname'] = '|{.Cookbook.Name}|'
default['|{.Cookbook.Name}|']['db-autocreate']['enabled'] = false
default['|{.Cookbook.Name}|']['demo']['enabled'] = false
default['|{.Cookbook.Name}|']['mysql']['databases'] = {}
default['|{.Cookbook.Name}|']['varnish']['backend_nodes'] = {}
default['|{.Cookbook.Name}|']['varnish']['multi'] = true

# Toggle newrelic application monitoring
default['stack_commons']['application_monitoring']['php']['enabled'] = true
# dirty hack to prevent stack_commons::newrelic to install php5.3 packages
default['php']['packages'] = []

# Apache-fpm
## there is a bug in mod_fastcgi, Magento <1.9 or EE <1.14 need this mod_fastcgi
# default['apache']['mod_fastcgi']['download_url'] = 'http://www.fastcgi.com/dist/mod_fastcgi-SNAP-0910052141.tar.gz'

# MySQL
default['mysql']['version'] = '5.6'
default['mysql-multi']['templates']['my.cnf']['cookbook'] = '|{.Cookbook.Name}|'
default['mysql-multi']['templates']['my.cnf']['source'] = 'mysql/my.cnf.erb'

# search query for discovery of nfs server
default['|{.Cookbook.Name}|']['nfs_server']['export_name'] = 'magento_media'
default['|{.Cookbook.Name}|']['nfs_server']['export_root'] = '/export'
default['|{.Cookbook.Name}|']['nfs_server']['discovery_query'] = "tags:|magento_nfs_server AND chef_environment:#{node.chef_environment}"

# clients
default['|{.Cookbook.Name}|']['nfs_client']['mount_point'] = '/mnt/magento_media'
default['|{.Cookbook.Name}|']['nfs_client']['symlink_target'] = 'media' # within /var/www/html/magento
