require_relative 'spec_helper'

describe "|{ cookbook['name'] }|::|{ options['name'] }|" do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }
  it 'installs nginx' do
    expect(chef_run).to install_apt_package('nginx')
  end
  it 'creates /etc/nginx.conf' do
    expect(chef_run).to create_template('/etc/nginx.conf')
  end
  it 'enables nginx' do
    expect(chef_run).to enable_service('nginx')
  end
end
