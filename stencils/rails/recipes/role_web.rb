#
# Cookbook Name:: |{ cookbook['name'] }|
# Recipe :: |{ options['name'] }|
#
# Copyright |{ cookbook['year'] }|, Rackspace
#

# You can bootstrap new servers with knife rackspace, follike the following:
# knife rackspace server create -N"dev-1" \
# -r"recipe[|{ cookbook['name'] }|], recipe[|{ cookbook['name'] }|::role_web]," \
# -E"dev" -I"598a4282-f14b-4e50-af4c-b3e52749d9f9" -f"performance1-4" \
# --no-tcp-test-ssh --ssh-wait-timeout 60 --secret-file path/to/secret \
# --network "dev" --rackspace-version v2

# Base platform

# You'll probably want Ruby and a webserver
include_recipe "#{cookbook_name}::_ruby"
include_recipe "#{cookbook_name}::_nginx"
# include_recipe "#{cookbook_name}::_apache"

# Our test application (and _many_ Ruby applications require a JavaScript runtime)
# We'll include NodeJS
include_recipe "#{cookbook_name}::_nodejs"

# Some other stencils which are very common in a Rails environment:
# include_recipe "#{cookbook_name}::_rackspace_networks"
# include_recipe "#{cookbook_name}::_glusterfs"
# include_recipe "#{cookbook_name}::_haproxy"
# include_recipe "#{cookbook_name}::_ha-redis"

# Applications!
app1 = |{ qstring(options['name']) }|
include_recipe "#{cookbook_name}::app_#{app1}"
