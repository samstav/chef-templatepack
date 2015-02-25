require_relative 'spec_helper'

describe "|{ cookbook['name'] }|::|{ options['name'] }|" do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }
  it 'installs mariadb-server' do
    expect(chef_run).to install_apt_package('mariadb-server')
  end
  it 'creates /etc/mysql/my.cnf' do
    expect(chef_run).to create_template('/etc/mysql/my.cnf')
  end
  it 'enables mysql' do
    expect(chef_run).to enable_service('mysql')
  end
end
