# Encoding: utf-8
#
# Cookbook Name:: |{.Cookbook.Name}|
# Recipe:: |{.Options.Name}|
#
# Copyright |{.Cookbook.Year}|, Rackspace Hosting
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
include_recipe 'nfs::default' # ~RACK002
nfs_server_node, export_name, export_root = MagentostackUtil.best_nfs_server(node)
return unless nfs_server_node && export_name && export_root

mount_point_path = node['|{.Cookbook.Name}|']['nfs_client']['mount_point']

directory mount_point_path

mount mount_point_path do
  device "#{nfs_server_node}:#{export_root}/#{export_name}"
  fstype 'nfs'
  options 'rw'
end

# check at runtime for directory, remove it if it exists, as we can't do this at compile time
# because we may install/unzip/create magento directories during convergence
ruby_block 'check for magento media directory at converge time' do
  block do
    if File.exist?("#{node['|{.Cookbook.Name}|']['web']['dir']}/media") && !File.symlink?("#{node['|{.Cookbook.Name}|']['web']['dir']}/media")
      dir = run_context.resource_collection.find(directory: "#{node['|{.Cookbook.Name}|']['web']['dir']}/media")
      dir.action :delete
    end
  end
end

directory "#{node['|{.Cookbook.Name}|']['web']['dir']}/media" do
  recursive true
  action :nothing # see ruby block above
end

link "#{node['|{.Cookbook.Name}|']['web']['dir']}/media" do
  to mount_point_path
end
