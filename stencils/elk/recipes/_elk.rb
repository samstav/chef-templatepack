#
# Cookbook Name:: |{ cookbook['name'] }|
# Recipe :: |{ options['name'] }|
#
# Copyright |{ cookbook['year'] }|, Rackspace
#

# secrets = Chef::EncryptedDataBagItem.load('secrets', 'kibana')
node.run_state['elkstack_kibana_username'] = 'changeme'
node.run_state['elkstack_kibana_password'] = 'changeme_password'

node.default['elkstack']['iptables']['enabled'] = nil
node.default['elkstack']['config']['iptables'] = false

node.override['elasticsearch']['version'] = '1.4.3'
node.override['elasticsearch']['filename'] = "elasticsearch-#{node['elasticsearch']['version']}.tar.gz"
node.override['elasticsearch']['download_url'] = [
  node['elasticsearch']['host'],
  node['elasticsearch']['repository'],
  node['elasticsearch']['filename']
].join('/')

include_recipe 'runit'
include_recipe 'elkstack::java'
include_recipe 'elkstack::cluster'

# An example log input
logstash_config 'server' do
  action 'create'
  templates_cookbook cookbook_name
  templates 'demo_input_rails.conf' => 'input_rails.conf.erb'
end

# Monitoring configuration
unless node.deep_fetch('testkitchen')
  include_recipe 'elkstack::newrelic'
end

tag('logstash_server')
