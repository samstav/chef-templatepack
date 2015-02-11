#
# Cookbook Name:: |{ .Cookbook.Name }|
# Recipe :: |{ .Options.Name }|
#
# Copyright |{ .Cookbook.Year }|, Rackspace
#

# # Default to assuming our server is a 1gb slice
system_total_mem_mb = '1024'
# If we have more information than that, get the systems total memory in MB
unless node['memory']['total'].nil?
  system_total_mem_mb = (node['memory']['total'].gsub(/kB/, '').to_i / 1024).round
end
# By default, we'll use one 3rd of it for Redis - adjust according to your needs
node.default['redisio']['default_settings']['maxmemory'] = "#{(system_total_mem_mb / 3).round}M"

# Consider using "rackspace_networks" stencil for easy networking magic :)
if node['address_map'].nil?
  # Use servicenet by default - NOT RECOMMENED - flip to false and make use of a cloud network
  # see "rackspace_networks" for more.
  iface = 'eth1'
  node.default['address_map']['service_net_iface'] = iface
  listen_address = node['network']['interfaces'][iface]['addresses'].find do |addr, addr_info|
    addr_info[:family] == 'inet'
  end
  node.default['redisio']['default_settings']['address'] = listen_address.first
else
  node.default['redisio']['default_settings']['address'] = node['address_map']['my_ip']
end

|{ if eq .Options.Cache "true" }|
node.default['redisio']['default_settings']['maxmemorypolicy'] = 'allkeys-lru'
node.default['redisio']['default_settings']['save'] = nil
|{ end }|

|{ if eq .Options.Cluster "true" }|
redis_master_address = node['address_map']['app_node_ips'].first
redis_port = node['address_map']['redis_port'] + 1

if redis_master_address == node['address_map']['my_ip'] || redis_master_address.nil?
  node.default['redisio']['servers'] = [
    {
      name: 'pool0',
      port: redis_port
    }
  ]
else
  node.default['redisio']['servers'] = [
    {
      name: 'pool0',
      port: redis_port,
      slaveof: {
        address: redis_master_address,
        port: redis_port
      }
    }
  ]
end

unless redis_master_address.nil?
  node.default['redisio']['sentinels'] = [{
    name: 'pool0',
    sentinel_port: 26_379,
    master_ip: redis_master_address,
    master_port: redis_port
  }]
end

if node.default['address_map']['app_node_ips'].length > 0
  if tagged?('redis_sentinel')
    node.default['redisio']['sentinel']['manage_config'] = false
  end
  tag('redis_sentinel')
  tag('redis')
end
include_recipe 'redisio'
include_recipe 'redisio::enable'
include_recipe 'redisio::sentinel'
include_recipe 'redisio::sentinel_enable'
|{ else }|
node.default['redisio']['servers'] = [
  {
    name: 'pool0',
    port: 6379
  }
]
|{ if eq .Options.Cache "true" }|
node.default['redisio']['servers'][0]['save'] = nil
|{ end }|
include_recipe 'redisio'
include_recipe 'redisio::enable'
|{ end }|
# End redis recipe
