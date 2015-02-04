#
# Cookbook Name:: |{.Name}|
# Recipe :: default
#
# Copyright |{ .Year }|, Rackspace
#

# Fix the locale on Ubuntu systems
case node['platform']
when 'debian', 'ubuntu'
  node.default['chef_client']['locale'] = 'en_US.UTF-8'
  include_recipe 'locale'
  ENV['LANG'] = node['locale']['lang']
  ENV['LC_ALL'] = node['locale']['lang']
end

node.default['authorization']['sudo']['passwordless'] = true

# Rackspace support, system users, and PlatformStack by default
include_recipe 'users::sysadmins'
include_recipe 'platformstack::rackops_rolebook'
