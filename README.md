Template pack for FastFood
-----

# Usage
1. Download release of fastfood: `pip install fastfood`

2. Setup a fastfood.json which is used to generate your cookbook - see examples below.

3. Clone the template pack locally so that you can contribute :)

4. ```fastfood --template-pack ../path/to/chef-templatepack --cookbooks . build example.json```

# FYI

Please keep in mind these templates are meant to be fairly generic. There is no replacment for knowing Chef! Please be sure to READ the recipes which are output - you'll undoubted need to modify them (which is the entire point of template cookbooks).

## General guidelines:
  - All recipes are Ubuntu centric with 2nd class support for CentOS.
  - Multi flavor support (ie: Ubuntu v CentOS etc) is handled in the stencil's Jinja code - NOT by the recipe itself. See the PHP stencil for an example of this.
  - Files which contain jinja markup should hold the extension .jinja2 for clarity. Files which do not contain any jinja2 markup do not need the extension.
  - Extensive tests are welcome, but keep in mind complex tests may fail during a build, slowing down a racker. Consider stubbed out or commented out complex tests - allowing a cookbook builder to enable them later at ease when ready.

# Stecil documentation:

### Apache
  A recipe which installs and configures Apache 2.4 from upstream repos. This version of apache supports ProxyPass and therefore PHP-FPM. We'll use MPM_EVENT by default, with some nice example for various kinds of applications :)

### Application-PHP
  An example PHP application. Very generic, but ships with a decent structure and deploy recipe - enough to get started deploying any PHP application.

### Drupal
  A complete example Drupal 7 app. Complete with Redis plugins, deploy cycle, database setup, etc. Even comes with a sample Drupal7 app :)

### GlusterFS
  The GlusterFS recipe is currently meant to be extremely simple. Gluster is a very complex piece of software, which can be configured a huge number of ways. Our default example is VERY simple, and will essentially keep directories synced with the lowest possible overhead (a basic replacement for LSYNC, etc). Should you heavily modify this for a more complex setup, please contribute the recipe upstream! :)

### ha-redis
  An example Redis setup with a Highly Available (HAProxy) redis pool. This is typical of a PHP Session pool. This recipe comes bundled with a handful of examples for common setups including one HA pool and one local pool for common web-app caching patterns.

### Mariadb
  A Modern MySQL drop in replacement with automatic tuning. MariaDB 10.0 is fully supported by most modern applications which support MySQL (Wordpress, Drupal, etc). Automatic tuning means an effective system from a 1gb to a 32gb cloud server :)

### Mariadb-galera
  The MariaDB 10.0 Galera Cluster recipe featuring automatic Galera cluster configuration. Keep in mind Galera is _NOT_ a drop in replacement for MySQL. Use with care!

### Memcached
  A tuned and easy-to-configure Memcached recipe.

### NewRelic

### Nginx
  Installs and configured NGINX - Very basic recipe, no frills.

### NodeJS
  Installs NodeJS and NPM from binary based on a defined version. Short and sweet!

### PHP
  Installs and configures a modern PHP - PHP5.6 with OPCache. The important thing to note here is that we're aiming for all installs to use PHP-FPM, PHP5.6, OpCache, and OpCache's "invalidate_timestamps" - this allows us to cache all compiled PHP scripts _forever_. A php-fpm reload is _required_ to reread changes off disk. In dev this is automatically disabled. See the OpCache tempalte for more information.

### Rackspace_networks
  A helper recipe which automatically determines a nodes best listening address and the best addresses of each other node in the environment. Supports intelligent Rackspace-centric decision making such as "use service net" or determining the network address of a server within a Cloud Network. Including this recipe and understanding it is highly recommeneded by the author for _all_ Rackspace customers :)

### Rails
  An example Ruby on Rails application! Comes bundled with a Unicorn server example.

### Redis
  A simple Redis recipe without HAProxy providing only one pool

### Ruby
  A recipe which allows easy management of Ruby installations via RBENV

### Varnish
  A Varnish4 recipe for modern LAMP stack applications

### Wordpress
  A complete example wordpress featuring Redis caching support

## Example stencil manifests:
### Wordpress
```json
{
  "name": "my_wordpress_cookbook",
  "stencils": [
    {
      "stencil_set": "wordpress",
      "name": "mywebsite.com",
      "repository": "http://github.com/erulabs/wordpress_test"
    },
    {
      "name": "_php",
      "stencil_set": "php"
    },
    {
      "name": "_nginx",
      "stencil_set": "nginx",
      "example": "php"
    },
    {
      "name": "_mariadb",
      "stencil_set": "mariadb"
    }
  ]
}
```

### Drupal
```json
{
  "name": "my_drupal_cookbook",
  "stencils": [
    {
      "stencil_set": "drupal",
      "name": "mywebsite.com",
      "repository": "http://github.com/erulabs/drupal_test"
    },
    {
      "name": "_php",
      "stencil_set": "php"
    },
    {
      "name": "_nginx",
      "stencil_set": "nginx",
      "example": "php"
    },
    {
      "name": "_mariadb",
      "stencil_set": "mariadb"
    }
  ]
}
```

### Ruby on Rails

  You'll most likely want to include a few other stencils here - such as MongoDB, MySQL, Memcached, Redis, NodeJS, or other common Rails tag-alongs.

```json
{
  "name": "my_rails_cookbook",
  "stencils": [
    {
      "name": "mywebsite.com",
      "stencil_set": "rails"
    },
    {
      "name": "_ruby",
      "stencil_set": "ruby"
    },
    {
      "name": "_nginx",
      "stencil_set": "nginx",
      "example": "rails"
    },
    {
      "name": "_mariadb",
      "stencil_set": "mariadb"
    }
  ]
}
```

### LAMP

  This is a slightly more complete LAMP stack featuring Varnisn, GlusterFS and Apache 2.4 with PHP-FPM.

  While perhaps not common anymore, this showcases many stencils in action which are easy to use for your own purposes.

```json
{
  "name": "my_lamp_cookbook",
  "stencils": [
    {
      "name": "mywebsite.com",
      "stencil_set": "application-php"
    },
    {
      "name": "_php",
      "stencil_set": "php"
    },
    {
      "name": "_apache",
      "stencil_set": "apache",
      "example": "php-fpm"
    },
    {
      "name": "_mariadb",
      "stencil_set": "mariadb"
    },
    {
      "name": "_varnish",
      "stencil_set": "varnish"
    },
    {
      "name": "_glusterfs",
      "stencil_set": "glusterfs",
      "mount_path": "/var/www/shared"
    }
  ]
}
```
