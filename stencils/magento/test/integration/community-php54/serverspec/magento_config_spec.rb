require 'spec_helper'

describe '|{.Cookbook.Name}| xml configuration' do
  describe 'Redis password for session' do
    describe file('/var/www/html/magento/app/etc/local.xml') do
      its(:content) { should match(/<password>runstatepasswordsingle<\/password>/) }
    end
  end
end