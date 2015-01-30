# Encoding: utf-8
#
# Cookbook Name:: |{.Cookbook.Name}|
# Recipe:: redis_sentinel
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

# find a master to watch
master_name, master_ip, master_port = MagentokUtil.best_redis_session_master(node)
unless master_name && master_ip && master_port
  Chef::Log.warn('|{.Cookbook.Name}|::redis_sentinel did not find a redis single master to configure a redis slave, not proceeding')
  return
end

Chef::Log.info("Choosing this sentinel's master to be #{master_name} (#{master_ip}:#{master_port}) ")
bind_port = node['|{.Cookbook.Name}|']['redis']['bind_port_sentinel']
server_name = "#{bind_port}-sentinel"
node.set['|{.Cookbook.Name}|']['redis']['sentinels'][server_name] = {
  'name' => server_name,
  'sentinel_port' => bind_port,
  'auth-pass' => MagentoUtil.redis_session_password(node),
  'master_ip' => master_ip,
  'master_port' => master_port
}
tag('magento_redis')
tag('magento_redis_sentinel')
MagentoUtil.recompute_redis(node, 'sentinels')
