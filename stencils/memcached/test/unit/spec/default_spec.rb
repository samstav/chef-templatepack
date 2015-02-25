require_relative 'spec_helper'

describe "|{ cookbook['name'] }|::|{ options['name'] }|" do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }
  it 'installs memcached' do
    expect(chef_run).to install_apt_package('memcached')
  end
  it 'creates /etc/memcached.conf' do
    expect(chef_run).to create_template('/etc/memcached.conf')
  end
  it 'enables memcached' do
    expect(chef_run).to enable_service('memcached')
  end
end
