# Encoding: utf-8
#
# Cookbook Name:: |{.Cookbook.Name}|
# Recipe:: nfs_server
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
include_recipe 'nfs::server' # ~RACK002

override_allow = node['|{.Cookbook.Name}|']['nfs_server']['override_allow']
if override_allow || Chef::Config[:solo]
  found_clients = override_allow
else
  found_clients = partial_search(:node, "chef_environment:#{node.chef_environment}",
                                 keys: {
                                   'name' => ['name'],
                                   'ip'   => ['ipaddress'],
                                   'cloud' => ['provider', 'local_ipv4', 'public_ipv4']
                                 }
  ).map { |n| best_ip_for(n) }
end

Chef::Log.warn('Did not find any clients to permit on NFS export of media') unless found_clients && !found_clients.empty?

# self-ip or localhost
self_ip = best_ip_for(node) || '127.0.0.1'
found_clients << self_ip

export_directory = node['|{.Cookbook.Name}|']['nfs_server']['export_root']
directory export_directory do
  user 'root'
  mode '0755'
end

export_name = node['|{.Cookbook.Name}|']['nfs_server']['export_name']
export_full_path = "#{export_directory}/#{export_name}"
directory export_full_path do
  user 'root'
  mode '0755'
end

nfs_export export_full_path do
  network found_clients.compact # remove nil
  writeable true
  sync true
  options ['no_root_squash']
end

# save to help the client recipe find me if it's also running on this same node
tag('magento_nfs_server')
node.save unless Chef::Config[:solo]
