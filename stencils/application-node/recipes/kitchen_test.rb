#
# Cookbook Name:: |{ cookbook['name'] }|
# Recipe :: |{ options['name'] }|
#
# Copyright |{ cookbook['year'] }|, Rackspace
#

# This cookbook is only intended as an easy to use base for
# testing the upstream stencil. I recommend removing this file
# and modifying the .kitchen.yml appropreately to better match
# how you chose to setup your actual live environments.

include_recipe "#{cookbook_name}::default"
include_recipe "#{cookbook_name}::role_app"
