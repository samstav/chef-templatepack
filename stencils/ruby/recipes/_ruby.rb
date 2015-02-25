#
# Cookbook Name:: |{ cookbook['name'] }|
# Recipe :: |{ options['name'] }|
#
# Copyright |{ cookbook['year'] }|, Rackspace
#

%w(
  rbenv::default
  rbenv::ruby_build
).each do |r|
  include_recipe r
end

node.default['ruby']['version'] = '2.1.2'

rbenv_ruby node['ruby']['version'] do
  global true
end

%w(
  rake
  bundler
).each do |g|
  rbenv_gem g
end
