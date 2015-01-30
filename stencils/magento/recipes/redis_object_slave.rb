# Encoding: utf-8
#
# Cookbook Name:: |{.Cookbook.Name}|
# Recipe:: redis_object_slave
#
# Copyright |{.Cookbook.Year}|, Rackspace US, Inc.
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

# required by libraries/util.rb
include_recipe 'chef-sugar'

master_name, master_ip, master_port = MagentoUtil.redis_find_masters(node) do |name, data|
  name.include?('-object-master') && !name.include?('slave')
end

unless master_name && master_ip && master_port
  Chef::Log.warn('Did not find a redis object master to configure a redis slave, not proceeding')
  return
end

bind_port = node['|{.Cookbook.Name}|']['redis']['bind_port_object_slave']
server_name = "#{bind_port}-object-slave"
node.set['|{.Cookbook.Name}|']['redis']['servers'][server_name] = {
  'name' => server_name,
  'port' => bind_port,
  'requirepass' => MagentoUtil.redis_object_password(node),
  'masterauth' => MagentoUtil.redis_object_password(node),
  'slaveof' => { 'master_name' => master_name, 'address' => master_ip, 'port' => master_port }
}
tag('magento_redis')
tag('magento_redis_object_slave')
MagentostackUtil.recompute_redis(node)
