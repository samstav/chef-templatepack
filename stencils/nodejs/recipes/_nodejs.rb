#
# Cookbook Name:: |{ cookbook['name'] }|
# Recipe :: |{ options['name'] }|
#
# Copyright |{ cookbook['year'] }|, Rackspace
#

['npm', 'node', 'nodejs', 'nodejs-legacy'].each do |node_pkg|
  package node_pkg do
    action :purge
  end
end

node_version = '0.10.33'
npm_version = '2.1.3'

# MD5 Checksum of http://nodejs.org/dist/v0.10.33/node-v0.10.33-linux-x64.tar.gz
# or /var/chef/cache/nodejs-binary-0.10.33.tar.gz on node
node.override['nodejs']['version'] = node_version
node.override['nodejs']['binary']['checksum'] = '1efad7c248b453ee6c62a706f6f86dbe'
# If you're using Rackspace's nodestack, you'll want to override the node version:
node.override['nodestack']['binary_path'] = "/usr/local/nodejs-binary-#{node_version}/bin/node"

include_recipe 'nodejs::nodejs_from_binary'

# Remove symlink if we need to install a new npm
file '/usr/local/bin/npm' do
  action :delete
  not_if "if [ `/usr/local/bin/npm -v` == '#{npm_version}' ]; then true; fi"
end

execute 'Modern NPM' do
  command "/usr/local/nodejs-binary-#{node['nodejs']['version']}/bin/npm \
install -g npm@#{npm_version}"
  not_if "if [ `/usr/local/bin/npm -v` == '#{npm_version}' ]; then true; fi"
end

