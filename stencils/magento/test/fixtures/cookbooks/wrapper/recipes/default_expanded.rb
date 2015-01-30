#
# Cookbook Name:: wrapper
# Recipe:: default_expanded
#
# Copyright 2014, Rackspace
#

# This wrapper's default recipe is intended to build a single node magento
# installation with all components split apart (such as separate redis instances)
#
# Add more recipes in the wrapper for other topologies/configurations of |{.Cookbook.Name}|.
%w(
  wrapper::_redis_password
  |{.Cookbook.Name}|::redis_object
  |{.Cookbook.Name}|::redis_object_slave
  |{.Cookbook.Name}|::redis_page
  |{.Cookbook.Name}|::redis_page_slave
  |{.Cookbook.Name}|::redis_session
  |{.Cookbook.Name}|::redis_session_slave
  |{.Cookbook.Name}|::redis_sentinel
  |{.Cookbook.Name}|::redis_configure
  |{.Cookbook.Name}|::apache-fpm
  |{.Cookbook.Name}|::magento_install
  |{.Cookbook.Name}|::nfs_server
  |{.Cookbook.Name}|::nfs_client
  |{.Cookbook.Name}|::mysql_master
  |{.Cookbook.Name}|::newrelic
  |{.Cookbook.Name}|::_find_mysql
  |{.Cookbook.Name}|::magento_configure
  |{.Cookbook.Name}|::magento_admin
  |{.Cookbook.Name}|::mysql_holland
).each do |recipe|
  include_recipe recipe
end

# if enterprise edition, also enable the FPC for testing
if node['|{.Cookbook.Name}|'] && node['|{.Cookbook.Name}|']['flavor'] == 'enterprise'
  include_recipe '|{.Cookbook.Name}|::_magento_fpc'
end
