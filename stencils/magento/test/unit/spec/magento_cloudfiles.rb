# Encoding: utf-8

require_relative 'spec_helper'

describe '|{.Cookbook.Name}|::magento enterprise with cloudfiles install' do
  before { stub_resources }
  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        cached(:chef_run) do
          ChefSpec::ServerRunner.new(platform: platform, version: version) do |node, server|
            node_resources(node) # stub this node
            stub_nodes(platform, version, server) # stub other nodes for chef-zero
            stub_environments(server)

            node.set['rackspace']['cloud_credentials']['username'] = 'foo'
            node.set['rackspace']['cloud_credentials']['api_key'] = 'bar'

            node.set['|{.Cookbook.Name}|']['flavor'] = 'enterprise'
            node.set['|{.Cookbook.Name}|']['install_method'] = 'cloudfiles'
            node.set['|{.Cookbook.Name}|']['download_file'] = 'magento-ee-1.14.0.1.tar.gz'
            node.set['|{.Cookbook.Name}|']['checksum'] = '1e3657778ecac9f1d0470326afdaddad36a88e2fa58b650749eb35d446e71868'

            # Stub the node and any calls to Environment.Load to return this environment
            env = Chef::Environment.new
            env.name 'chefspec' # matches ./test/integration/
            allow(node).to receive(:chef_environment).and_return(env.name)
            allow(Chef::Environment).to receive(:load).and_return(env)
          end.converge('|{.Cookbook.Name}|::magento_install',
                       '|{.Cookbook.Name}|::redis_single',
                       '|{.Cookbook.Name}|::_find_mysql',
                       '|{.Cookbook.Name}|::magento_configure')
        end

        it 'gets magento and extract it' do
          expect(chef_run).to create_rackspacecloud_file("#{Chef::Config[:file_cache_path]}/magento-ee-1.14.0.1.tar.gz")
          expect(chef_run).to put_ark('magento').with(action: [:put], url: "file://#{Chef::Config[:file_cache_path]}/magento-ee-1.14.0.1.tar.gz")
        end
      end
    end
  end
end
