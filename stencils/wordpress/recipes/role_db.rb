#
# Cookbook Name:: |{.Cookbook.Name}|
# Recipe :: |{.Options.Name}|
#
# Copyright |{ .Cookbook.Year }|, Rackspace
#

# Base platform
include_recipe "#{cookbook_name}::_rackspace_networks"
include_recipe "#{cookbook_name}::_mariadb"

# Databases!
app1 = |{.QString .Options.Name}|
include_recipe "#{cookbook_name}::db_#{app1}"
