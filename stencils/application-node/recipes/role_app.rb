#
# Cookbook Name:: |{ cookbook['name'] }|
# Recipe :: |{ options['name'] }|
#
# Copyright |{ cookbook['year'] }|, Rackspace
#

# You'll want to include and install NodeJS - checkout the nodejs/iojs stencil :)
include_recipe "#{cookbook_name}::_nodejs"

# And typically place a webserver in front of Node
include_recipe "#{cookbook_name}::_nginx"
node.default['app-node']['webserver'] = node['nginx']['user']

nodejs_npm 'pm2' # We'll use PM2 for application managment :)
nodejs_npm 'gulp' # A lot of apps make use of build systems like GULP as well.
package 'build-essential' # It's very common for node apps to want to compile things

# Applications!
# Note that sometimes you'll want to break apart the inclusion of applications directly into the servers runlist.
# in other words, a server might have the "role_app" recipe applied as well as a few sites directly.
# However, in most situations, putting all sites on all "app" servers is typically what is wanted.
app1 = |{ qstring(options['name']) }|
include_recipe "#{cookbook_name}::app_#{app1}"
