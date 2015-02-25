require_relative 'spec_helper'

describe "|{ cookbook['name'] }|::|{ options['name'] }|" do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }
  it 'installs apache2' do
    expect(chef_run).to install_apt_package('apache2')
  end
  it 'deletes /etc/apache2/sites-enabled/default' do
    expect(chef_run).to delete_file('/etc/apache2/sites-enabled/default')
  end
  it 'creates /etc/apache2/apache2.conf' do
    expect(chef_run).to create_template('/etc/apache2/apache2.conf')
  end
  it 'enables apache2' do
    expect(chef_run).to enable_service('apache2')
  end
end
