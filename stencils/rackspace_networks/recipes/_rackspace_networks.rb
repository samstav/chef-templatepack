#
# Cookbook Name:: |{ cookbook['name'] }|
# Recipe :: |{ options['name'] }|
#
# Copyright |{ cookbook['year'] }|, Rackspace
#

# Set Hosts file entries automatically
set_hosts_file = true

# Address map - a list of all nodes
node.default['address_map']['app_nodes'] = []
node.default['address_map']['app_node_ips'] = []
# And the same list without myself, for ease of use.
node.default['address_map']['other_nodes'] = []
node.default['address_map']['other_node_ips'] = []
# Keep a list of servers based on their tags - a convience for other recipes
node.default['address_map']['redis_masters'] = []
node.default['address_map']['mysql_masters'] = []
node.default['address_map']['logstash_servers'] = []

# We'll assume the private network you want to connect to is at 'eth2' by default
# This may not be true depending on your configuration.
node.default['address_map']['cloud_net_iface'] = 'eth2'
node.default['address_map']['cloud_net_label'] = node.chef_environment

# If you dont want to use service_net (OnMetal does not support Cloud Networks)
# Note that this cookbook WILL NOT deal with firewalling for you.
# It is COMPLETELY up to you to firewall approprately.
# I do not open everything up, as we do with a private network.
node.default['address_map']['use_service_net'] = false
node.default['address_map']['service_net_iface'] = 'eth1'

# We'll always assume to be listening locally unless we find evidence suggesting we should use
# some other network
node.default['address_map']['my_ip'] = '127.0.0.1'

# Determine our own IP address
# If we're not on Rackspace, or we're using Chef-solo
if !node['rackspace'].nil? && !Chef::Config[:solo]
  if node['address_map']['use_service_net']
    iface = node['address_map']['service_net_iface']
    ips = node['network']['interfaces'][iface]['addresses'].find do |addr, addr_info|
      addr_info[:family] == 'inet'
    end
    node.default['address_map']['my_ip'] = ips.first
  elsif !node['rackspace']['private_networks'].nil?
    mynetwork = node['rackspace']['private_networks'].find do |network|
      network['label'] == node['address_map']['cloud_net_label']
    end
    if mynetwork.nil?
      log "ADDRESS_MAP: Warning, no private network found named #{node['address_map']['cloud_net_label']}"
      log 'ADDRESS_MAP: Falling back to using 127.0.0.1'
    else
      node.default['address_map']['my_ip'] = mynetwork['ips'].first['ip']
      # Ensure the private network is whitelisted
      add_iptables_rule('INPUT', "-i #{node['address_map']['cloud_net_iface']} \
  -j ACCEPT", 50, 'allow all traffic on private network')
    end
  end
end

# Add a hostsfile entry
hostsfile_entry node['address_map']['my_ip'] do
  hostname node.name
  unique true
  only_if { set_hosts_file == true }
end

# Build the map of other nodes and their addresses
# If we're local or not on Rackspace, assume we're a standalone node
if node['rackspace'].nil? || Chef::Config[:solo]
  node.default['address_map']['mysql_masters'] << '127.0.0.1'
  node.default['address_map']['redis_masters'] << '127.0.0.1'
else
  all_nodes_raw = search(:node, "chef_environment:#{node.chef_environment}")
  # Sort nodes by name to ensure consistent ordering
  all_nodes_raw.sort! { |a, b| a.name <=> b.name }
  if !all_nodes_raw.nil? && !all_nodes_raw.empty? && !all_nodes_raw.first.nil?
    all_nodes_raw.each do |app_node|
      # Skip ourselves for no
      next if app_node.name == node.name
      # This can occur if the foriegn node is _currently_ bootstrapping
      next if app_node['rackspace'].nil?
      if node['address_map']['use_service_net']
        iface = node['address_map']['service_net_iface']
        best_ip = app_node['network']['interfaces'][iface]['addresses'].find do |addr, addr_info|
          addr_info[:family] == 'inet'
        end
        best_ip = best_ip.first
      elsif !app_node['rackspace']['private_networks'].nil?
        privatenet = app_node['rackspace']['private_networks'].find do |netwrk|
          netwrk['label'] == node['address_map']['cloud_net_label']
        end
        next if privatenet.nil?
        best_ip = privatenet['ips'].first['ip']
      end
      # Sometimes, the foriegn node does not have any details yet. This can occur
      # if the node failed to bootstrap, but still shows in Chef's node list
      next if best_ip.nil?
      hostsfile_entry best_ip do
        hostname app_node.name
        unique true
        only_if { set_hosts_file == true }
      end
      # Populate helper arrays - this is what we're here to do
      node.default['address_map']['other_nodes'] << app_node.name
      node.default['address_map']['other_node_ips'] << best_ip
      if app_node['tags'].include? 'mysql_master'
        node.default['address_map']['mysql_masters'] << best_ip
      end
      if app_node['tags'].include? 'redis'
        node.default['address_map']['redis_masters'] << best_ip
      end
      if app_node['tags'].include? 'logstash_server'
        node.default['address_map']['logstash_servers'] << best_ip
      end
      # If we're using servicenet, and not a private network
      # We'll whitelist JUST the node
      # Note that this does not allow seamless bootstrapping, as there is a chicken-before-egg issue
      # as new nodes will not be whitelisted before they bootstrap, and will therefore fail.
      if node['address_map']['use_service_net']
        add_iptables_rule('INPUT', "-i #{node['address_map']['service_net_iface']}\
 -s #{best_ip} -j ACCEPT", 50, 'allow all traffic on private network')
      end
    end
  end
  node.default['address_map']['app_nodes'] = node['address_map']['other_nodes']
  node.default['address_map']['app_nodes'] << node.name
  node.default['address_map']['app_node_ips'] = node['address_map']['other_node_ips']
  node.default['address_map']['app_node_ips'] << node['address_map']['my_ip']
end
