require_relative 'spec_helper'

describe "|{ cookbook['name'] }|::|{ options['name'] }|" do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }
  it 'installs haproxy' do
    expect(chef_run).to install_apt_package('haproxy')
  end
  it 'creates /etc/haproxy/haproxy.cfg' do
    expect(chef_run).to create_template('/etc/haproxy/haproxy.cfg')
  end
  it 'enables haproxy' do
    expect(chef_run).to enable_service('haproxy')
  end
end
