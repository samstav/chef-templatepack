# Encoding: utf-8
#
# Cookbook Name:: |{.Cookbook.Name}|
# Recipe:: redis_configure
#
# Copyright |{.Cookbook.Year}| Rackspace, US Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# this recipe should be called after every other |{.Cookbook.Name}|::redis_* recipe
# because the configure and enable recipes in redisio will complete the setup
# of all instances (redis and sentinel both)
%w(
  redisio::install
  redisio::configure
  redisio::enable
  redisio::sentinel
  redisio::sentinel_enable
).each do |recipe|
  include_recipe recipe
end
MagentoUtil.build_iptables(node) do |type, str, pri, comment|
  add_iptables_rule(type, str, pri, comment)
end
