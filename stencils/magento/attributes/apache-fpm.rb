# there is a bug in mod_fastcgi, Magento <1.9 or EE <1.14 need this mod_fastcgi
# only require if we decide to use Magento <1.9 or EE <1.14
# default['apache']['mod_fastcgi']['download_url'] = 'http://www.fastcgi.com/dist/mod_fastcgi-SNAP-0910052141.tar.gz'

# Configure default Magento Vhosts
default['|{.Cookbook.Name}|']['web']['domain'] = 'localhost'
default['|{.Cookbook.Name}|']['web']['http_port'] = '80'
default['|{.Cookbook.Name}|']['web']['https_port'] = '443'
default['|{.Cookbook.Name}|']['web']['server_aliases'] = node['fqdn']
default['|{.Cookbook.Name}|']['web']['ssl_autosigned'] = true
default['|{.Cookbook.Name}|']['web']['cookbook'] = '|{.Cookbook.Name}|'
default['|{.Cookbook.Name}|']['web']['template'] = 'apache2/magento_vhost.erb'
default['|{.Cookbook.Name}|']['web']['fastcgi_cookbook'] = '|{.Cookbook.Name}|'
default['|{.Cookbook.Name}|']['web']['fastcgi_template'] = 'apache2/fastcgi.conf'
default['|{.Cookbook.Name}|']['web']['dir'] = "#{node['apache']['docroot_dir']}/magento"

site_name = node['|{.Cookbook.Name}|']['web']['domain']
default['|{.Cookbook.Name}|']['web']['ssl_key'] = "#{node['apache']['dir']}/ssl/#{site_name}.key"
default['|{.Cookbook.Name}|']['web']['ssl_cert'] = "#{node['apache']['dir']}/ssl/#{site_name}.pem"

# Install php dependencies for Magento
default['|{.Cookbook.Name}|']['php']['version'] = 'php55'
case node['platform_family']
when 'rhel'
  default['|{.Cookbook.Name}|']['php55']['packages'] = %w(
    php55u-gd
    php55u-mysqlnd
    php55u-mcrypt
    php55u-xml
    php55u-xmlrpc
    php55u-soap
    php55u-pecl-redis
    php55u-opcache
  )

  default['|{.Cookbook.Name}|']['php54']['packages'] = %w(
    php54-gd
    php54-mysqlnd
    php54-mcrypt
    php54-xml
    php54-xmlrpc
    php54-soap
    php54-pecl-redis
    php54-opcache
  )
### opcache is built in Php for Ubuntu
when 'debian'
  default['|{.Cookbook.Name}|']['php']['packages'] = %w(
    php5-gd
    php5-mysqlnd
    php5-mcrypt
    php5-xmlrpc
    php5-redis
    php5-curl
  )
end
#    php5-soap

# Php configuration
default['php-fpm']['pools'] = {
  'www' => {
    enable: true,
    php_options: {
      'php_admin_flag[opcache.enable]' => '1',
      'php_admin_value[opcache.memory_consumption]' => '256',
      'php_admin_value[opcache.interned_strings_buffer]' => '8',
      'php_admin_value[opcache.max_accelerated_files]' => '4000',
      'php_admin_flag[opcache.fast_shutdown]' => '1',
      'php_admin_flag[opcache.validate_timestamps]' => '1',
      'php_admin_value[memory_limit]' => '512M',
      'php_admin_value[max_execution_time]' => '1800',
      'php_admin_value[realpath_cache_size]' => '256k',
      'php_admin_value[realpath_cache_ttl]' => '7200',
      'php_admin_value[open_basedir]' => 'none',
      'php_admin_value[session.entropy_length]' => '32',
      'php_admin_value[session.entropy_file]' => '/dev/urandom'
    }
  }
}
# cloud monitoring
node.default['|{.Cookbook.Name}|']['web']['monitor']['cookbook'] = '|{.Cookbook.Name}|'
node.default['|{.Cookbook.Name}|']['web']['monitor']['template'] = 'cloud-monitoring/monitoring-remote-http.yaml.erb'
node.default['|{.Cookbook.Name}|']['web']['monitor']['disabled'] = false
node.default['|{.Cookbook.Name}|']['web']['monitor']['period'] = 60
node.default['|{.Cookbook.Name}|']['web']['monitor']['timeout'] = 15
node.default['|{.Cookbook.Name}|']['web']['monitor']['alarm'] = false
