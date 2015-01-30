# DRY module. Repeating yourself? Put it in a library!
#  Be wary of the node variable here. Prefer to pass node in and out of your
#  methods to allow wrappers to override node values and have them take effect
#  within this library.
# rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity
module MagentoUtil
  def self.best_redis_session_master(current_node)
    return best_redis_master(current_node, 'session')
  end

  def self.best_redis_object_master(current_node)
    return best_redis_master(current_node, 'object')
  end

  def self.best_redis_page_master(current_node)
    return nil, nil, nil unless current_node['|{.Cookbook.Name}|']['flavor'] == 'enterprise'
    return best_redis_master(current_node, 'page')
  end

  def self.best_redis_master(current_node, type)
    # find a master to watch
    master_name, master_ip, master_port = nil, nil, nil

    # overrides for service discovery override, etc.
    name = current_node['|{.Cookbook.Name}|']['redis']["override_#{type}_name"]
    host = current_node['|{.Cookbook.Name}|']['redis']["override_#{type}_host"]
    port = current_node['|{.Cookbook.Name}|']['redis']["override_#{type}_port"]
    return name, host, port if name && host && port

    session_master_name, session_master_ip, session_master_port = MagentoUtil.redis_find_masters(current_node) do |n, data|
      n.include?("-#{type}-master") && !n.include?('slave')
    end
    single_master_name, single_master_ip, single_master_port = MagentoUtil.redis_find_masters(current_node) do |n, data|
      n.include?('-single-master') && !n.include?('slave')
    end

    # prefer session master over single master, for sentinel monitoring
    if session_master_name && session_master_ip && session_master_port
      master_name, master_ip, master_port = session_master_name, session_master_ip, session_master_port
    elsif single_master_name && single_master_ip && single_master_port
      master_name, master_ip, master_port = single_master_name, single_master_ip, single_master_port
    end

    if master_name && master_ip && master_port
      Chef::Log.info("best_redis_#{type}_master found best session master to be #{master_name}, #{master_ip}:#{master_port}")
    else
      Chef::Log.warn("best_redis_#{type}_master did not find any single master or #{type} master redis instances to monitor with sentinel, not proceeding")
    end

    return master_name, master_ip, master_port
  end

  # Determine each required iptables rule and call my_proc on it, considering
  # any slaves or sentinels that must connect inbound to this node
  def self.build_iptables(current_node, &my_proc)
    # just exit if there aren't any redis instances configured here
    return unless current_node &&
                  current_node['|{.Cookbook.Name}|'] &&
                  current_node['|{.Cookbook.Name}|']['redis'] &&
                  current_node['|{.Cookbook.Name}|']['redis']['servers']

    # get all redis nodes in the current chef environment (or custom query for it)
    redis_nodes = redis_discovery(current_node)

    # get all my redis instances (sentinels don't receive connections, so ignore them)
    local_redis_instances = redis_instance_info([current_node], current_node)
    local_redis_instances.each do |instance_name, instance_config|
      next unless instance_config['port']
      dest_port = instance_config['port']

      # loop through every remote instance
      redis_nodes.each do |other_node|
        other_node_ip = Chef::Sugar::IP.best_ip_for(current_node, other_node)
        comment = "Allow redis from #{other_node.name}/#{instance_name}:#{dest_port}"
        my_proc.call('INPUT', "-m tcp -p tcp -s #{other_node_ip} --dport #{dest_port} -j ACCEPT", 9998, comment)
      end
    end
  end

  # Discover redis instances and apply filter_proc for locating a single instance
  #  While this is called find_masters, it technically could be used on any
  #  search terms. It is master-specific in the data it returns about a particular
  #  redis instance (just what the master needs to connect)
  def self.redis_find_masters(current_node, &filter_proc)
    # find redis instances in the same chef environment
    redis_instances = MagentoUtil.redis_discovery(current_node)
    Chef::Log.debug("redis_find_masters found the following redis instances: #{redis_instances.map(&:name).join(', ')}")

    # lookup their redis data structure
    found_instances = MagentoUtil.redis_instance_info(redis_instances, current_node)

    if found_instances && !found_instances.empty?
      Chef::Log.debug("redis_find_masters found the following redis data on those instances: #{found_instances.keys.join(', ')}")
    else
      Chef::Log.info('redis_find_masters not find any redis instances')
      return
    end

    master_name, master_ip, master_port = nil, nil, nil

    # look for a master instance using the supplied filter
    masters = found_instances.select(&filter_proc)
    if masters && !masters.empty?
      if masters.count > 1
        Chef::Log.warn("redis_find_masters, after filtering, found more than one redis instance: #{masters.keys.join(', ')}")
      else
        Chef::Log.info("redis_find_masters, after filtering, found #{masters.count} masters: #{masters.keys.join(', ')}")
      end
      master_name, master_data = masters.first
      master_ip = master_data['best_ip_for']
      master_port = master_data['port']
    end

    if master_name && master_ip && master_port
      Chef::Log.debug("redis_find_masters, after filtering, chose #{master_name} (#{master_ip}:#{master_port}) ")
    elsif master_name || master_ip || master_port
      Chef::Log.warn("redis_find_masters, after filtering, chose #{master_name} (#{master_ip}:#{master_port}) - but was missing name, ip or port. Please file a bug.")
    else
      Chef::Log.info('redis_find_masters, after filtering, did not find any instances, not proceeding')
    end

    return master_name, master_ip, master_port
  end

  # Find all redis instances in the scope of the cookbook (see query below).
  #  The sentinel or slave recipes will use this data to figure out where the
  #  masters are (sentinel) or replicate from (slaves).
  #
  #  By default, it tries to just use the preset node['|{.Cookbook.Name}|']['redis']['discovery'].
  #  If that preset isn't available, under chef solo, it warns and finishes.
  #  Otherwise, it does a search using node['|{.Cookbook.Name}|']['redis']['discovery_query'].
  def self.redis_discovery(current_node)
    return discovery(current_node,
                     current_node.deep_fetch('|{.Cookbook.Name}|', 'redis', 'discovery'),
                     current_node.deep_fetch('|{.Cookbook.Name}|', 'redis', 'discovery_query'),
                     'redis_discovery')
  end

  def self.nfs_server_discovery(current_node)
    return discovery(current_node,
                     current_node.deep_fetch('|{.Cookbook.Name}|', 'nfs_server', 'discovery'),
                     current_node.deep_fetch('|{.Cookbook.Name}|', 'nfs_server', 'discovery_query'),
                     'nfs_server_discovery')
  end

  # Find all instances in the scope of the cookbook (see query below).
  #
  #  By default, it tries to just use the preset nodes
  #  If that preset isn't available, under chef solo, it warns and finishes.
  #  Otherwise, it does a search using supplied query
  def self.discovery(_current_node, preset_nodes, query, description)
    # use preset if it exists
    if preset_nodes
      Chef::Log.info("#{description} was already set to #{preset_nodes}")
      return preset_nodes
    end

    # if solo, just warn
    if Chef::Config[:solo]
      Chef::Log.warn('discovery recipe uses search if discovery attributes are not set.')
      Chef::Log.warn('Chef Solo does not support search in discovery.')
      return {}
    end

    # otherwise, do the search we want to discover other redis nodes
    found_nodes = []
    Chef::Search::Query.new.search('node', query) { |o| found_nodes << o }

    if found_nodes.nil? || found_nodes.count < 1
      Chef::Log.warn("#{description} did not find any nodes in discovery, but none were set")
      found_nodes = [] # so loop below exits
    else
      Chef::Log.debug("#{description} found nodes #{found_nodes.map(&:name).join(', ')}")
    end

    return found_nodes
  end

  # Given a list of node objects, produce a hash of redis instance that maps
  # instance names to a hash of instance configuration values as each hash value
  def self.instance_info(node_list, current_node, key_name)
    discovered_nodes = {}
    return discovered_nodes unless node_list

    node_list.each do |n|
      # n may not be a Chef::Node so we can't use node#deep_fetch from chef/sugar
      if n['|{.Cookbook.Name}|'] && n['|{.Cookbook.Name}|']['redis'] && n['|{.Cookbook.Name}|']['redis'][key_name]
        n['|{.Cookbook.Name}|']['redis'][key_name].each do |redis_name, redis_instance|
          found_data = redis_instance.to_hash
          found_data['best_ip_for'] = get_ip_by_name(n.name, current_node)
          discovered_nodes[redis_name] = found_data
          Chef::Log.debug("instance_info found node instance #{redis_name} (#{redis_instance})")
        end
      else
        Chef::Log.warn("instance_info found node #{n.name} but didn't see any data under its ['|{.Cookbook.Name}|']['redis']['#{key_name}'] attribute")
      end
    end

    return discovered_nodes
  end

  def self.redis_instance_info(redis_nodes, current_node)
    instance_info(redis_nodes, current_node, 'servers')
  end

  def self.sentinel_instance_info(redis_nodes, current_node)
    instance_info(redis_nodes, current_node, 'sentinels')
  end

  # Recompute node['redisio']['servers'] based on our node['|{.Cookbook.Name}|']['redis']['servers']
  #  This is needed because the redisio node attribute is an array, and we'd rather not search
  #  the array for duplicates every time we want to configure an instance.
  def self.recompute_redis(current_node, key_name = 'servers')
    return unless key_name && current_node['|{.Cookbook.Name}|']['redis'][key_name]

    redis_instances = []
    current_node['|{.Cookbook.Name}|']['redis'][key_name].each do |key, value|
      redis_instances.push(value)
    end
    current_node.set['redisio'][key_name] = redis_instances

    # we must save so that search works during the same chef run
    # or a sentinel will require 2 runs to converge
    current_node.save unless Chef::Config[:solo]
    Chef::Log.info("recompute_redis computed #{current_node.keys.join(', ')} instances")
    redis_instances
  end

  # Given a node name, look up the IP for that node based on the current node.
  #  This is here because best_ip_for(node) doesn't normally take strings, it needs
  #  a real node object so it can find the IPs on the node's attribute data. I
  #  wanted something that accepted a string for the redis discovery.
  def self.get_ip_by_name(node_name, current_node)
    results = []
    # the extra condition in the block below covers chef finding nodes with nested name keys that match
    Chef::Search::Query.new.search(:node, "name:#{node_name}") { |o| results << o if node_name == o.name }

    if results.count < 1
      found = nil
    else
      found = Chef::Sugar::IP.best_ip_for(current_node, results.first)
    end
    Chef::Log.debug("best_ip_for #{node_name} to be #{found}")

    found
  end

  # If there is redis password for the session storage then return it
  def self.redis_session_password(current_node)
    redis_password_or_single(current_node, 'session')
  end

  # If there is redis password for the object storage then use it
  def self.redis_object_password(current_node)
    redis_password_or_single(current_node, 'object')
  end

  # If there is redis password for the full page storage then use it
  def self.redis_page_password(current_node)
    redis_password_or_single(current_node, 'page')
  end

  def self.redis_single_password(current_node)
    get_runstate_or_attr(current_node, '|{.Cookbook.Name}|', 'redis', 'password_single')
  end

  def self.redis_password_or_single(current_node, password_type)
    password_single = redis_single_password(current_node)
    password_instance = get_runstate_or_attr(current_node, '|{.Cookbook.Name}|', 'redis', "password_#{password_type}")

    if password_single
      password_single
    else
      password_instance
    end
  end

  def self.best_nfs_server(current_node)
    # overrides for service discovery override, etc.
    host = current_node['|{.Cookbook.Name}|']['nfs_server']['override_host']
    export_name = current_node['|{.Cookbook.Name}|']['nfs_server']['export_name']
    export_root = current_node['|{.Cookbook.Name}|']['nfs_server']['export_root']

    return host, export_name, export_root if host

    hosts = nfs_server_discovery(current_node)
    host = hosts && !hosts.empty? && hosts.first

    ip_for_host = nil
    if host
      Chef::Log.info("best_nfs_server found best nfs server to be #{host}")
      ip_for_host = MagentoUtil.get_ip_by_name(host.name, current_node)
    else
      Chef::Log.warn('best_nfs_server did not find any nfs_server instance, not proceeding')
    end

    export_name = host && host['|{.Cookbook.Name}|'] && host['|{.Cookbook.Name}|']['nfs_server'] && host['|{.Cookbook.Name}|']['nfs_server']['export_name']
    export_root = host && host['|{.Cookbook.Name}|'] && host['|{.Cookbook.Name}|']['nfs_server'] && host['|{.Cookbook.Name}|']['nfs_server']['export_root']

    return ip_for_host, export_name, export_root
  end

  def self.get_runstate_or_attr(current_node, *attr)
    require 'chef/sugar'
    run_state_key = attr.join('_')
    if current_node.run_state.key?(run_state_key)
      current_node.run_state[run_state_key]
    else
      current_node.deep_fetch(*attr)
    end
  end
end
# rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity
