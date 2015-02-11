#
# Cookbook Name:: |{.Cookbook.Name}|
# Recipe :: |{.Options.Name}|
#
# Copyright |{ .Cookbook.Year }|, Rackspace
#

# Base platform
include_recipe "#{cookbook_name}::_rackspace_networks"
include_recipe "#{cookbook_name}::_glusterfs"
include_recipe "#{cookbook_name}::_nginx"
include_recipe "#{cookbook_name}::_php"
include_recipe "#{cookbook_name}::_redis"

# Applications!
app1 = |{.QString .Options.Name}|
include_recipe "#{cookbook_name}::site_#{app1}"
