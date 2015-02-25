#
# Cookbook Name:: |{ cookbook['name'] }|
# Recipe :: |{ options['name'] }|
#
# Copyright |{ cookbook['year'] }|, Rackspace
#

include_recipe "#{cookbook_name}::_nodejs"

link '/bin/node' do
  to '/usr/local/bin/node'
end

include_recipe 'statsd'
