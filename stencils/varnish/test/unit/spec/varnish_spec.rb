require_relative 'spec_helper'

describe "|{ cookbook['name'] }|::|{ options['name'] }|" do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }
  it 'installs varnish' do
    expect(chef_run).to install_apt_package('varnish')
  end
  it 'creates /etc/varnish/default.vcl' do
    expect(chef_run).to create_template('/etc/varnish/default.vcl')
  end
  it 'creates /etc/default/varnish' do
    expect(chef_run).to create_template('/etc/default/varnish')
  end
  it 'enables varnish' do
    expect(chef_run).to enable_service('varnish')
  end
end
