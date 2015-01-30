# Where to get Magento, can be http link or git path
default['|{.Cookbook.Name}|']['install_method'] = 'ark' # can be ark, git, cloudfiles, or none
default['|{.Cookbook.Name}|']['checksum'] = '338df88796a445cd3be2a10b5c79c50e9900a4a1b1d8e9113a79014d3186a8e0'
default['|{.Cookbook.Name}|']['flavor'] = 'community' # could also be enterprise

# for ark download method
default['|{.Cookbook.Name}|']['download_url'] = 'http://www.magentocommerce.com/downloads/assets/1.9.0.1/magento-1.9.0.1.tar.gz'

# for cloudfiles download method
default['|{.Cookbook.Name}|']['download_region'] = 'ORD'
default['|{.Cookbook.Name}|']['download_dir'] = 'magento'
default['|{.Cookbook.Name}|']['download_file'] = 'magento.tar.gz'

# for git download method
default['|{.Cookbook.Name}|']['git_repository'] = 'git@github.com:example/deployment.git'
default['|{.Cookbook.Name}|']['git_revision'] = 'master' # e.g. staging, testing, dev
default['|{.Cookbook.Name}|']['git_deploykey'] = nil

# Database creation
normal['|{.Cookbook.Name}|']['mysql']['databases']['magento_database']['mysql_user'] = 'magento_user'
normal['|{.Cookbook.Name}|']['mysql']['databases']['magento_database']['mysql_password'] = 'magento_password'
normal['|{.Cookbook.Name}|']['mysql']['databases']['magento_database']['privileges'] = ['all']
normal['|{.Cookbook.Name}|']['mysql']['databases']['magento_database']['global_privileges'] = [:usage, :select, :'lock tables', :'show view', :reload, :super]

# Magento configuration
## localisation
default['|{.Cookbook.Name}|']['config']['tz'] = 'Etc/UTC'
default['|{.Cookbook.Name}|']['config']['locale'] = 'en_US'
default['|{.Cookbook.Name}|']['config']['default_currency'] = 'GBP'

## Database
### run_state rather than default?
default['|{.Cookbook.Name}|']['config']['db']['prefix'] = 'magento_'
default['|{.Cookbook.Name}|']['config']['db']['model'] = 'mysql4'

## Admin user
default['|{.Cookbook.Name}|']['config']['admin_frontname'] = 'admin'
default['|{.Cookbook.Name}|']['config']['admin_user']['firstname'] = 'Admin'
default['|{.Cookbook.Name}|']['config']['admin_user']['lastname'] = 'User'
default['|{.Cookbook.Name}|']['config']['admin_user']['email'] = 'admin@example.org'
default['|{.Cookbook.Name}|']['config']['admin_user']['username'] = 'MagentoAdmin'
default['|{.Cookbook.Name}|']['config']['admin_user']['password'] = 'magPass.123'

## Other configs
default['|{.Cookbook.Name}|']['config']['session']['save'] = 'db'

default['|{.Cookbook.Name}|']['config']['use_rewrites'] = 'yes'
default['|{.Cookbook.Name}|']['config']['use_secure'] = 'yes'
default['|{.Cookbook.Name}|']['config']['use_secure_admin'] = 'yes'
default['|{.Cookbook.Name}|']['config']['enable_charts'] = 'yes'
