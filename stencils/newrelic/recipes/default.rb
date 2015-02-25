#
# Cookbook Name:: |{ cookbook['name'] }|
# Recipe :: |{ options['name'] }|
#
# Copyright |{ cookbook['year'] }|, Rackspace
#

newrelic_key = Chef::EncryptedDataBagItem.load(|{ options['databag'] }|, 'newrelic')
node.default['newrelic']['license'] = newrelic_key['key']

include_recipe 'newrelic::default'
