#
# Cookbook Name:: |{ cookbook['name'] }|
# Recipe :: |{ options['name'] }|
#
# Copyright |{ cookbook['year'] }|, Rackspace
#

# Base platform
# include_recipe "#{cookbook_name}::_rackspace_networks"
include_recipe "#{cookbook_name}::_mariadb"

# Databases!
app1 = |{ qstring(options['name']) }|
include_recipe "#{cookbook_name}::db_#{app1}"
