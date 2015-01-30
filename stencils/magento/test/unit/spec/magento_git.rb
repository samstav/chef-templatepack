# Encoding: utf-8

require_relative 'spec_helper'

describe '|{.Cookbook.Name}|::magento enterprise with git install' do
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
            node.set['|{.Cookbook.Name}|']['install_method'] = 'git'

            node.set['|{.Cookbook.Name}|']['git_repository'] = 'git@github.com:org/repo.git'
            node.set['|{.Cookbook.Name}|']['git_revision'] = 'master'
            node.set['|{.Cookbook.Name}|']['git_deploykey'] = 'Zm9vCg=='

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
          expect(chef_run).to sync_git('/var/www/html/magento')
        end
      end
    end
  end
end
