#
# Cookbook Name:: |{.Cookbook.Name}|
# Recipe :: |{.Options.Name}|
#
# Copyright |{ .Cookbook.Year }|, Rackspace
#

# This cookbook ought to be included by your WebServer role

# The webserver user - TODO: Smart detect
webserver_user = 'www-data'

# The application's name - used extensively
app_name = |{.QString .Options.Name}|
app_path = "/var/www/#{app_name}"

user app_name do
  comment "User for #{app_name} application"
  home app_path
end

# We'll assume you want to keep your applications secrets in a databag
# It should be an encrypted databag named "secrets", with an item matching the "app_name"
# It will need keys like so:
# [secrets][app_name]['deploy_key']
# [secrets][app_name]['db']['name']
# [secrets][app_name]['db']['user']
# [secrets][app_name]['db']['pass']
app_secrets = {}
begin
  app_secrets = Chef::EncryptedDataBagItem.load('secrets', app_name)
rescue
  Chef::Log.warn('No encrypted data bag found! Using default values')
  app_secrets['deploy_key'] = nil
  app_secrets['db'] = {}
  app_secrets['db']['name'] = 'CHANGE_ME'
  app_secrets['db']['user'] = 'CHANGE_ME_AS_WELL'
  app_secrets['db']['pass'] = 'FOR_SURE_CHANGE_ME'
end

# Branch selection process
case node.chef_environment
when 'prd'
  branch = 'production'
when 'stg'
  branch = 'stage'
when 'dev'
  branch = 'master'
end

# Find MySQL master - TODO: Remove reliance on rackspace_networks "address_map"
if tagged?('mysql_master')
  db_host = node['address_map']['my_ip']
else
  db_host = node['address_map']['mysql_masters'].first
end

# Deploy the application - see https://docs.getchef.com/resource_deploy.html
application app_name do
  path app_path
  owner app_name
  group webserver_user
  repository |{.QString .Options.Repository}|
  deploy_key app_secrets['deploy_key']
  revision branch
  before_symlink do
    # Make sure you write your own wp-config...
    # 9 times out of 10 the default provided by this recipe will not be a close enough match
    # to a developed wordpress. Take the customers wp-config, template-ize it, and replace the stock one provided
    # by this template.
    template "#{release_path}/wp-config.php" do
      mode '0775'
      owner webserver_user
      group webserver_user
      source "sites/#{app_name}/wp-config.php.erb"
      variables(
        db_name: app_secrets['db']['name'],
        db_user: app_secrets['db']['user'],
        db_password: app_secrets['db']['pass'],
        db_host: db_host
      )
    end
    # Redis page cache
    template "#{release_path}/index.php" do
      mode '0775'
      owner webserver_user
      group webserver_user
      source "sites/#{app_name}/redis-index.php.erb"
    end

    # Link uploads and cache directories to ../shared so that they persist between deploys
    # Typically, the ../shared directory will be a GlusterFS mount shared between all nodes
    paths_to_create = [ 'shared/wp-content', 'wp-content/uploads', 'wp-content' ]
    paths_to_create.each do |path_to_create|
      directory "#{app_path}/#{path_to_create}" do
        mode '0770'
        owner app_name
        group webserver_user
      end
    end
    link "#{release_path}/wp-content/uploads" do
      to "#{app_path}/shared/wp-content/uploads"
    end
    directory "#{app_path}/shared/wp-content/cache" do
      mode '0777'
      owner app_name
      group webserver_user
    end
    link "#{release_path}/wp-content/cache" do
      to "#{app_path}/shared/wp-content/cache"
    end
    directory "#{app_path}/shared/wp-content/w3tc-config" do
      mode '0770'
      owner app_name
      group webserver_user
    end

    # If you're using W3TotalCache, and want to share w3tc-config between deployments
    # You can link it into the shared directory. This is useful if each environment wants a default
    # w3tc config to start with, but will be maintained and persisted between deployments
    # link "#{release_path}/wp-content/w3tc-config" do
    #   to "#{app_path}/shared/wp-content/w3tc-config"
    # end
    # file "#{release_path}/wp-content/advanced-cache.php" do
    #   owner app_name
    #   group webserver_user
    #   mode 0755
    #   content ::File.open("#{release_path}/wp-content/plugins/w3-total-cache/wp-content/advanced-cache.php").read
    #   action :create
    # end

    # To sync an entire application to the CDN during each deploy, you can use "cloudsink"
    # You'll need to make sure NodeJS is installed and you've installed the "cloudsink" npm
    # See https://github.com/erulabs/cloudsink
    # execute "sink_#{app_name}_to_CDN" do
    #  cwd release_path
    #  command "cloudsink -s wp-content -t #{app_name}-cdn -r IAD \
    # -S -F -u #{node['rackspace']['cloud_credentials']['username']}\
    # -k #{node['rackspace']['cloud_credentials']['api_key']} \
    # -f '*.css,*.jpg,*.ico,*.png,*.bmp,*.js'"
    # end
  end
  after_restart do
    # Because we'll be setting OPCache's revalidate time to never, we'll HAVE to reload PHP-FPM on deployments
    # Otherwise no php files will be reloaded from disk.
    execute 'service php5-fpm reload'
    # We'll also clear Varnishs cache by banning on objects for this site (not required unless using varnish, of course)
    # execute "clear_varnish_for_#{app_name}" do
    #   command "varnishadm 'ban req.http.host ~ #{app_name}'"
    #   ignore_failure true
    # end
    # This could probably be improved - we should ideally only clear the cache of the keys we actually
    # want to invalidate. However, this is the most _sane_ option, although perhaps not the most performant.
    execute 'redis-cli flushall'
    # Here is an example of using MailGun to send email notifications on deployments
    # execute "curl -s --user 'api:#{node.default['mailgun_api_key']}' \
    # https://api.mailgun.net/v2/seandonmooy.com/messages \
    # -F from='Chef <chef-client@#{node['address_map']['my_ip']}>' \
    # -F to='seandon.mooy@gmail.com' \
    # -F subject='Chef-client: Deployed #{app_name} to #{node.chef_environment} on #{node.name}' \
    # -F text='This mail was sent by #{node.name} at #{node['address_map']['my_ip']}'"

    # And here is an example of using SendGrid to send email notifications
    # execute "send_deployment_notification_for_#{app_name}" do
    #   command "curl -X POST https://api.sendgrid.com/api/mail.send.json \
    # -d 'api_user=#{node['sendgrid_username']}' \
    # -d 'api_key=#{node['sendgrid_api_key']}' \
    # -d 'to=systems@uvisionconsulting.com' \
    # -d 'from=chef-client@music.com' \
    # -d 'subject=Chef-client: Deployed #{app_name} to #{node.chef_environment} on #{node.name}' \
    # -d 'html=Deployed to #{release_path} <br> \
    # This mail was sent by #{node.name} at #{node['address_map']['my_ip']}<br>'"
    # end
    # And Slack.com!
    # execute "send_slack_notification_for_#{app_name}" do
    #   command "curl -X POST --data-urlencode 'payload={\"channel\": \"#CHANNEL_NAME_HERE\",\
    # \"username\": \"Chef-Client\", \"text\": \"#{node.name} deployed #{app_name} to #{release_path}\", \
    # \"icon_emoji\": \":fork_and_knife:\"}' https://hooks.slack.com/SLACK_HOOK_URL"
    # end
  end
end

# Configure Nginx (testing)
template "/etc/nginx/sites-enabled/#{app_name}.conf" do
  source "sites/#{app_name}/nginx-site.erb"
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    appname: app_name
  )
  notifies :reload, 'service[nginx]'
end

# Configure Apache
# template "/etc/apache2/sites-enabled/#{app_name}.conf" do
#   source "sites/#{app_name}/apache-site.erb"
#   owner 'root'
#   group 'root'
#   mode '0644'
#   variables(
#     appname: app_name
#   )
#   notifies :reload, 'service[apache2]'
# end

logrotate_app "#{app_name}-access" do
  path '/var/log/nginx/#{app_name}-access.log'
  rotate 1000
  frequency 'daily'
  options %w(missingok compress dateext copytruncate)
end
