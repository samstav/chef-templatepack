# don't let redisio setup for us, empty instances as default
override['redisio']['bypass_setup'] = true
# (nil makes redisio create default instances, empty array does not)
default['redisio']['servers'] = []
default['redisio']['sentinels'] = []

# for a single instance, this is the bind port
default['|{.Cookbook.Name}|']['redis']['bind_port_single'] = '6379'
default['|{.Cookbook.Name}|']['redis']['bind_port_single_slave'] = '6380'

# for a separate session cache instance, this is the bind port
default['|{.Cookbook.Name}|']['redis']['bind_port_session'] = '6381'
default['|{.Cookbook.Name}|']['redis']['bind_port_session_slave'] = '6382'

# for a separate object cache instance, this is the bind port
default['|{.Cookbook.Name}|']['redis']['bind_port_object'] = '6383'
default['|{.Cookbook.Name}|']['redis']['bind_port_object_slave'] = '6384'

# for a separate full page cache instance, this is the bind port
default['|{.Cookbook.Name}|']['redis']['bind_port_page'] = '6385'
default['|{.Cookbook.Name}|']['redis']['bind_port_page_slave'] = '6386'

# for sentinel instances to use as a bind port
default['|{.Cookbook.Name}|']['redis']['bind_port_sentinel'] = '46379'

# search query for discovery
default['|{.Cookbook.Name}|']['redis']['discovery_query'] = "tags:|{.Cookbook.Name}|_redis AND chef_environment:#{node.chef_environment}"

# overrides for chef-solo, other dependency injection
# default['|{.Cookbook.Name}|']['redis']['override_page_name'] = 'example01'
# default['|{.Cookbook.Name}|']['redis']['override_page_host'] = 'localhost'
# default['|{.Cookbook.Name}|']['redis']['override_page_port'] = '123'
# default['|{.Cookbook.Name}|']['redis']['override_session_name'] = 'example01'
# default['|{.Cookbook.Name}|']['redis']['override_session_host'] = 'localhost'
# default['|{.Cookbook.Name}|']['redis']['override_session_port'] = '123'
# default['|{.Cookbook.Name}|']['redis']['override_object_name'] = 'example01'
# default['|{.Cookbook.Name}|']['redis']['override_object_host'] = 'localhost'
# default['|{.Cookbook.Name}|']['redis']['override_object_port'] = '123'
