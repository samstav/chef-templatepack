#
# Cookbook Name:: |{ cookbook['name'] }|
# Recipe :: |{ options['name'] }|
#
# Copyright |{ cookbook['year'] }|, Rackspace
#

rackspace_cloud_monitoring_service 'default' do
  cloud_credentials_username node['rackspace_cloud_monitoring']['cloud_credentials_username']
  cloud_credentials_api_key node['rackspace_cloud_monitoring']['cloud_credentials_api_key']
  action [:create, :start]
end

rackspace_cloud_monitoring_check 'cpu' do
  type 'agent.cpu'
  alarm true
  action :create
end

rackspace_cloud_monitoring_check 'load' do
  type 'agent.load'
  alarm true
  action :create
end

rackspace_cloud_monitoring_check 'memory' do
  type 'agent.memory'
  alarm true
  action :create
end

ignored_fs_types = %w(cgroup configfs devpts devtmpfs
                      efivars fusectl mqueue proc pstore
                      securityfs sys sysfs tmpfs xenfs)

node['filesystem'].each do |k, v|
  next if v['fs_type'].nil? ||
          v['percent_used'].nil? ||
          ignored_fs_types.include?(v['fs_type'])
  rackspace_cloud_monitoring_check "#{k}" do
    type 'agent.filesystem'
    target "#{v['mount']}"
    alarm true
    action :create
  end
end
