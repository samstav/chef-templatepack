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

# You'll probably want PHP and a webserver
include_recipe "#{cookbook_name}::_php"
include_recipe "#{cookbook_name}::_nginx"
# include_recipe "#{cookbook_name}::_apache"

# include_recipe "#{cookbook_name}::_rackspace_networks"
# include_recipe "#{cookbook_name}::_glusterfs"
# include_recipe "#{cookbook_name}::_haproxy"
include_recipe "#{cookbook_name}::_haredis"

# Applications!
app1 = |{ qstring(options['name']) }|
include_recipe "#{cookbook_name}::site_#{app1}"
