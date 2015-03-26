Template pack for FastFood
-----
[![Circle CI](https://circleci.com/gh/erulabs/seandons_templatepack/tree/master.png)](https://circleci.com/gh/erulabs/seandons_templatepack/tree/master)


# Usage
1. Download release of fastfood: `pip install fastfood`

2. Setup a fastfood.json which is used to generate your cookbook - see examples below.

3. Clone the template pack locally so that you can contribute :)

4. ```fastfood --template-pack ../path/to/chef-templatepack --cookbooks . build example.json```

5. Use foodcourt to browse stencils and options: http://erulabs.github.io/seandons_templatepack/foodcourt/build/

# FYI

Please keep in mind these templates are meant to be fairly generic. There is no replacment for knowing Chef! Please be sure to READ the recipes which are output - you'll undoubted need to modify them (which is the entire point of template cookbooks).

## General guidelines:
  - Please use GitHub issues or [Waffle.io](https://waffle.io/erulabs/seandons_templatepack) for development tasks
  - Files which contain jinja markup should hold the extension .jinja2 for clarity. Files which do not contain any jinja2 markup do not need the extension.
  - Extensive tests are welcome.

## Stencil Manifest API Guidelines
  For the most part, we use the default Fastfood manifest syntax. Because we append additional information to the manfiest API (for the sake of foodcourt, our stencil generation UI, but also sometimes because we're waiting on a PR for fastfood) and because Fastfood's manifest is hillariously undocumented, the following provides a simple reference. JSON doesn't support comments, so strip out the comments if copy-pasting:
```javascript
{
  // A string representing the name of the stencil - must match the name in the stencil pack's manifest.
  "id": "drupal",
  // Fastfood API version - always 1 for now
  "api": 1,
  // Of the stencils this stencil provides, which ones should we use by default?
  // This is a slightly annoying feature.
  // My recommendation is to have the default match the stencil's name, and have the stencil
  // provide only one... stencil. As you can imagine, a single stencil housing multiple others
  // Gets very confusing and opaque very quickly.
  "default_stencil": "drupal",
  // Metadata.rb cookbook dependencies. Adding things here is equivilent to "depends 'KEY'"
  "dependencies": {
    "drush": {},
    "application": {},
    "users": {},
    "logrotate": {}
  },
  // Berks file dependencies
  "berks_dependencies": {
    "nodejs": {
      "git": "https://github.com/erulabs/nodejs"
    }
  },
  // Options which are passed to the Jinja Templating system
  "options": {
    // The key is the name of the option
    "name": {
      // A nice description
      "help": "Name of the drupal application",
      // The default value for this option (if no value is defined)
      "default": "drupal_example.com"
    },
    "repository": {
      "help": "The URI of the application's git repository",
      "default": "http://github.com/erulabs/wordpress_test"
    },
    "webserver": {
      "help": "Which webserver should we provide an example for?",
      "default": "nginx",
      // Should the options be a set, rather than an input string
      // You can provide "options" here. Keep in mind fastfood doesn't use this at all
      // However, foodcourt will automatically create a nice HTML Select form for you should you fill this out.
      "options": ["nginx", "apache"]
    }
  },
  // Which stencils does this stencil pack provide?
  // Again, my suggestion is to have one stencil pack provide one stencil.
  "stencils": {
    "drupal": {
      "files": {
        // Which files should we copy from our stencil into the cookbook, and where?
        // Keep in mind this is reversed:
        // DESTINATION: SOURCE
        // In the DESTINATION, the "NAME" option can be used:
        // "recipes/site_<NAME>.rb": "recipes/_drupal.rb.jinja2",
        // This would create "recipes/site_drupal_example.com.rb"
        // Note the "default" value of "name" above.
        "recipes/site_<NAME>.rb": "recipes/_drupal.rb.jinja2",
        "recipes/db_<NAME>.rb": "recipes/_database.rb",
        "recipes/role_db.rb": "recipes/role_db.rb",
        "recipes/role_web.rb": "recipes/role_web.rb",
        "recipes/kitchen_test.rb": "recipes/kitchen_test.rb",
        "templates/default/sites/<NAME>/nginx-site.erb": "templates/default/nginx-site.erb",
        "templates/default/sites/<NAME>/setup.sql.erb": "templates/default/setup.sql.erb",
        "templates/default/sites/<NAME>/settings.php.erb": "templates/default/nginx-site.erb",
        "test/unit/spec/<NAME>_spec.rb": "test/unit/spec/drupal_spec.rb"
      },
      // A list of directories to create. Dont use this.
      // The logic for creating the directories is awful
      // Additionally, directories are created recursively ahead of time based on file paths from "files"
      "directories": [
        "test",
        "recipes"
      ],
      // Which options should we pass to this stencil?
      // Not typically used when creating single-stencil stencil-packs.
      "options": {
      }
    }
  }
}
```

# Stencil documentation:

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

### HAProxy
  A short example HAProxy recipe with a handful of common examples.

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
  Installs NodeJS and NPM from binary based on a defined version. Short and sweet! Also features support for io.js

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
Please visit [FoodCourt](http://erulabs.github.io/seandons_templatepack/foodcourt/build/) for example stencils.
