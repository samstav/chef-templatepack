require_relative 'spec_helper'

describe "|{ cookbook['name'] }|::|{ options['name'] }|" do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }
  it 'installs php5' do
    expect(chef_run).to install_apt_package('php5')
  end
  it 'creates /etc/php5/fpm/php.ini' do
    expect(chef_run).to create_template('/etc/php5/fpm/php.ini')
  end
  it 'enables php5-fpm' do
    expect(chef_run).to enable_service('php5-fpm')
  end
end
