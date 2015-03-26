#
# Cookbook Name:: |{ cookbook['name'] }|
# Recipe :: default
#
# Copyright |{ cookbook['year'] }|, Rackspace
#

# Include the package manager helper recipes
case node['platform']
when 'debian', 'ubuntu'
  # Fix locale on Ubuntu
  node.default['chef_client']['locale'] = 'en_US.UTF-8'
  include_recipe 'locale'
  ENV['LANG'] = node['locale']['lang']
  ENV['LC_ALL'] = node['locale']['lang']
  include_recipe 'apt'
when 'redhat', 'centos', 'fedora', 'amazon', 'scientific'
  include_recipe 'yum'
end

node.default['authorization']['sudo']['passwordless'] = true

# Rackspace support, system users, and PlatformStack by default
include_recipe 'users::sysadmins'
include_recipe 'platformstack::rackops_rolebook'
