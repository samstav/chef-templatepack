# Encoding: utf-8

require_relative 'spec_helper'

describe '|{.Cookbook.Name}|::newrelic' do
  before { stub_resources }
  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        let(:chef_run) do
          ChefSpec::ServerRunner.new(platform: platform, version: version, log_level: ::LOG_LEVEL) do |node, server|
            node_resources(node)
          end.converge(described_recipe)
        end

        it 'includes recipes' do
          expect(chef_run).to include_recipe('stack_commons::newrelic')
          expect(chef_run).to include_recipe('newrelic::php_agent')
        end
      end
    end
  end
end
