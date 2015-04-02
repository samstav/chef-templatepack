/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};

/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {

/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;

/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};

/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);

/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;

/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}


/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;

/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;

/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";

/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ function(module, exports, __webpack_require__) {

	/* global angular */
	"use strict";

	var app = angular.module("foodcourt", []);
	var manifest = __webpack_require__(3);

	app.controller("stencilController", function ($scope) {
	  $scope.stencils = manifest.stencil_sets;
	  $scope.stencilsData = {};
	  for (var stencilName in manifest.stencil_sets) {
	    $scope.stencilsData[stencilName] = __webpack_require__(1)("./" + stencilName + "/manifest.json");
	  }

	  var stencilPacks = ["node", "wordpress"];
	  $scope.stencilPacks = {};
	  stencilPacks.forEach(function (stencilPackName) {
	    $scope.stencilPacks[stencilPackName] = __webpack_require__(2)("./" + stencilPackName + ".json");
	  });

	  $scope.base = manifest.base;
	  $scope.api = manifest.api;
	  $scope.framework = manifest.framework;
	  $scope.selectedStencils = {};
	  $scope.numStencils = 0;
	  $scope.manifest_output = false;

	  $scope.selectStencil = function (name) {
	    $scope.selectedStencils[name] = $scope.stencilsData[name];
	    $scope.numStencils += 1;
	    $scope.buildManifest();
	  };

	  $scope.selectStencilPack = function (name) {
	    var stencils = $scope.stencilPacks[name].stencils;
	    for (var stencil in stencils) {
	      delete stencils[stencil].$$hashKey;
	    }
	    $scope.selectedStencils = {};
	    $scope.numStencils = 0;
	    $scope.manifest_output = $scope.prettyJson({
	      name: "My_new_cookbook",
	      stencils: stencils
	    });
	  };

	  $scope.removeStencil = function (name) {
	    $scope.selectedStencils[name] = undefined;
	    delete $scope.selectedStencils[name];
	    $scope.numStencils -= 1;
	    $scope.buildManifest();
	  };

	  $scope.openStencilOptions = function (name) {
	    $scope.selectedStencils[name].open = true;
	  };

	  $scope.closeStencilOptions = function (name) {
	    $scope.selectedStencils[name].open = false;
	  };

	  $scope.prettyJson = function (input) {
	    return JSON.stringify(input, null, 2);
	  };

	  $scope.prettyDeps = function (input) {
	    if (input === undefined) {
	      return "";
	    }
	    return Object.keys(input).join(", ");
	  };

	  $scope.buildManifest = function () {
	    var output = {
	      name: "My_new_cookbook",
	      stencils: []
	    };
	    for (var _name in $scope.selectedStencils) {
	      var stencil = $scope.selectedStencils[_name];
	      var obj = {
	        stencil_set: _name
	      };
	      for (var optName in stencil.options) {
	        var option = stencil.options[optName];
	        if (option.choice !== undefined) {
	          obj[optName] = option.choice;
	        }
	      }
	      output.stencils.push(obj);
	    }
	    $scope.manifest_output = $scope.prettyJson(output);
	  };
	});

/***/ },
/* 1 */
/***/ function(module, exports, __webpack_require__) {

	var map = {
		"./application-node/manifest.json": 6,
		"./ha-redis/manifest.json": 7,
		"./mariadb/manifest.json": 8,
		"./nginx/manifest.json": 9,
		"./nodejs/manifest.json": 10,
		"./php/manifest.json": 11,
		"./rackspace_networks/manifest.json": 12,
		"./wordpress/manifest.json": 13
	};
	function webpackContext(req) {
		return __webpack_require__(webpackContextResolve(req));
	};
	function webpackContextResolve(req) {
		return map[req] || (function() { throw new Error("Cannot find module '" + req + "'.") }());
	};
	webpackContext.keys = function webpackContextKeys() {
		return Object.keys(map);
	};
	webpackContext.resolve = webpackContextResolve;
	module.exports = webpackContext;
	webpackContext.id = 1;


/***/ },
/* 2 */
/***/ function(module, exports, __webpack_require__) {

	var map = {
		"./node.json": 4,
		"./wordpress.json": 5
	};
	function webpackContext(req) {
		return __webpack_require__(webpackContextResolve(req));
	};
	function webpackContextResolve(req) {
		return map[req] || (function() { throw new Error("Cannot find module '" + req + "'.") }());
	};
	webpackContext.keys = function webpackContextKeys() {
		return Object.keys(map);
	};
	webpackContext.resolve = webpackContextResolve;
	module.exports = webpackContext;
	webpackContext.id = 2;


/***/ },
/* 3 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = {
		"api": 1,
		"framework": "chef",
		"stencil_sets": {
			"nodejs": {
				"help": "Installs NodeJS and provides an NPM LWRP"
			},
			"nginx": {
				"help": "Creates a standalone Nginx instance"
			},
			"application-node": {
				"help": "Creates an example NodeJS application recipe"
			},
			"rackspace_networks": {
				"help": "A utility for working with Rackspace Cloud Networks, ServiceNet and PublicNet"
			},
			"wordpress": {
				"help": "Creates an example Wordpress application"
			},
			"mariadb": {
				"help": "A modern MySQL system"
			},
			"php": {
				"help": "Creates a standalone PHP instance"
			},
			"ha-redis": {
				"help": "Creates a highly available Redis and HAProxy recipe"
			}
		},
		"base": {
			"files": [
				".gitignore",
				".kitchen.yml",
				"Berksfile",
				"CHANGELOG.md",
				"Gemfile",
				"fastfood.json",
				"metadata.rb",
				"Rakefile",
				"README.md",
				"TROUBLESHOOTING.md",
				"recipes/default.rb",
				"test/unit/spec/default_spec.rb",
				"test/unit/spec/spec_helper.rb",
				"test/integration/encrypted_data_bag_secret",
				"test/integration/default/serverspec/spec_helper.rb",
				"test/integration/default/serverspec/default_spec.rb"
			],
			"directories": [
				"attributes",
				"files",
				"libraries",
				"providers",
				"recipes",
				"resources",
				"templates",
				"test/unit/spec",
				"test/integration/data_bags",
				"test/integration/default/serverspec"
			]
		}
	}

/***/ },
/* 4 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = {
		"name": "my_node_cookbook",
		"stencils": [
			{
				"name": "mywebsite.com",
				"stencil_set": "application-node"
			},
			{
				"stencil_set": "nodejs"
			},
			{
				"stencil_set": "nginx"
			}
		]
	}

/***/ },
/* 5 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = {
		"name": "my_wordpress_cookbook",
		"stencils": [
			{
				"stencil_set": "wordpress",
				"name": "mywebsite.com",
				"repository": "http://github.com/erulabs/wordpress_test"
			},
			{
				"stencil_set": "php"
			},
			{
				"stencil_set": "nginx",
				"example": "php"
			},
			{
				"stencil_set": "mariadb"
			},
			{
				"stencil_set": "ha-redis",
				"example": "php"
			},
			{
				"stencil_set": "rackspace_networks"
			}
		]
	}

/***/ },
/* 6 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = {
		"id": "application-node",
		"api": 1,
		"default_stencil": "application-node",
		"dependencies": {
			"application": {},
			"users": {},
			"logrotate": {}
		},
		"stencil_combos": {
			"nodejs": {},
			"nginx": {}
		},
		"options": {
			"name": {
				"help": "Name of the Node application",
				"default": "node_example.com"
			},
			"repository": {
				"help": "The URI of the application's git repository",
				"default": "http://github.com/erulabs/node_test"
			},
			"entry_point": {
				"help": "The name of the script to run (ie: `node server/index.js`)",
				"default": "server/index.js"
			}
		},
		"stencils": {
			"application-node": {
				"files": {
					"recipes/app_<NAME>.rb": "recipes/_nodeapp.rb.jinja2",
					"recipes/role_app.rb": "recipes/role_app.rb",
					"recipes/kitchen_test.rb": "recipes/kitchen_test.rb",
					"templates/default/apps/<NAME>/nginx-site.erb": "templates/default/nginx-site.erb",
					"test/integration/default/serverspec/<NAME>_spec.rb": "test/integration/default/serverspec/nodeapp_spec.rb"
				},
				"options": {}
			}
		}
	}

/***/ },
/* 7 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = {
		"id": "ha-redis",
		"default_stencil": "ha-redis",
		"api": 1,
		"dependencies": {
			"redisio": {}
		},
		"options": {
			"name": {
				"help": "Name of the recipe to create",
				"default": "_haredis"
			},
			"example": {
				"help": "Various premade HA Redis examples",
				"default": "basic"
			}
		},
		"stencils": {
			"ha-redis": {
				"files": {
					"recipes/<NAME>.rb": "recipes/_haredis.rb.jinja2",
					"recipes/_haproxy.rb": "recipes/_haproxy.rb.jinja2",
					"templates/default/haproxy.cfg.erb": "templates/default/haproxy.cfg.erb"
				}
			}
		}
	}

/***/ },
/* 8 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = {
		"id": "mariadb",
		"default_stencil": "mariadb",
		"api": 1,
		"dependencies": {
			"database": {},
			"apt": {},
			"yum": {},
			"ulimit": {}
		},
		"options": {
			"name": {
				"help": "Name of the recipe to create",
				"default": "_mariadb"
			}
		},
		"stencils": {
			"mariadb": {
				"options": {},
				"files": {
					"recipes/<NAME>.rb": "recipes/_mariadb.rb.jinja2",
					"templates/default/mariadb/.my.cnf.erb": "templates/default/.my.cnf.erb",
					"templates/default/mariadb/constants.sql.erb": "templates/default/constants.sql.erb",
					"templates/default/mariadb/my.cnf.erb": "templates/default/my.cnf.erb",
					"templates/default/mariadb/server-seed.erb": "templates/default/server-seed.erb"
				}
			}
		}
	}

/***/ },
/* 9 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = {
		"id": "nginx",
		"api": 1,
		"default_stencil": "nginx",
		"dependencies": {
			"rackspace_iptables": {},
			"ulimit": {}
		},
		"options": {
			"name": {
				"help": "Name of the recipe to create",
				"default": "_nginx"
			},
			"example": {
				"help": "Various premade Nginx examples",
				"default": "basic"
			}
		},
		"stencils": {
			"nginx": {
				"files": {
					"recipes/<NAME>.rb": "recipes/_nginx.rb",
					"templates/default/nginx/nginx.conf.erb": "templates/default/nginx.conf.erb.jinja2"
				},
				"options": {}
			}
		}
	}

/***/ },
/* 10 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = {
		"id": "nodejs",
		"api": 1,
		"default_stencil": "nodejs",
		"dependencies": {
			"nodejs": {}
		},
		"berks_dependencies": {
			"nodejs": {
				"git": "https://github.com/erulabs/nodejs"
			}
		},
		"options": {
			"name": {
				"help": "Name of the recipe to create",
				"default": "_nodejs"
			}
		},
		"stencils": {
			"nodejs": {
				"files": {
					"recipes/<NAME>.rb": "recipes/_nodejs.rb",
					"test/integration/default/serverspec/<NAME>_spec.rb": "test/integration/default/serverspec/nodejs_spec.rb"
				},
				"options": {}
			}
		}
	}

/***/ },
/* 11 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = {
		"id": "php",
		"api": 1,
		"default_stencil": "php",
		"dependencies": {
			"apt": {},
			"yum": {},
			"composer": {}
		},
		"options": {
			"name": {
				"help": "Name of the recipe to create",
				"default": "_php"
			}
		},
		"stencils": {
			"php": {
				"files": {
					"recipes/<NAME>.rb": "recipes/_php.rb.jinja2",
					"templates/default/php/php.ini.erb": "templates/default/php/php.ini.erb",
					"templates/default/php/pool.conf.erb": "templates/default/php/pool.conf.erb",
					"templates/default/php/php-fpm.conf.erb": "templates/default/php/php-fpm.conf.erb",
					"templates/default/php/05_opcache.ini.erb": "templates/default/php/05_opcache.ini.erb"
				},
				"options": {}
			}
		}
	}

/***/ },
/* 12 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = {
		"id": "rackspace_networks",
		"default_stencil": "rackspace_networks",
		"api": 1,
		"dependencies": {
			"hostsfile": {}
		},
		"options": {
			"name": {
				"help": "Name of the recipe to create",
				"default": "_rackspace_networks"
			}
		},
		"stencils": {
			"rackspace_networks": {
				"files": {
					"recipes/<NAME>.rb": "recipes/_rackspace_networks.rb"
				}
			}
		}
	}

/***/ },
/* 13 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = {
		"id": "wordpress",
		"api": 1,
		"default_stencil": "wordpress",
		"dependencies": {
			"wp-cli": {},
			"application": {},
			"users": {},
			"logrotate": {}
		},
		"options": {
			"name": {
				"help": "Name of the wordpress application",
				"default": "wordpress_example.com"
			},
			"repository": {
				"help": "The URI of the application's git repository",
				"default": "http://github.com/erulabs/wordpress_test"
			},
			"webserver": {
				"help": "Which webserver should we provide an example for? Choose 'nginx'/'apache'",
				"default": "nginx"
			}
		},
		"stencils": {
			"wordpress": {
				"files": {
					"recipes/site_<NAME>.rb": "recipes/_wordpress.rb.jinja2",
					"recipes/db_<NAME>.rb": "recipes/_database.rb",
					"recipes/role_db.rb": "recipes/role_db.rb",
					"recipes/role_web.rb": "recipes/role_web.rb",
					"recipes/kitchen_test.rb": "recipes/kitchen_test.rb",
					"templates/default/sites/<NAME>/redis-index.php.erb": "templates/default/redis-index.php.erb",
					"templates/default/sites/<NAME>/object-cache.php.erb": "templates/default/object-cache.php.erb",
					"templates/default/sites/<NAME>/nginx-site.erb": "templates/default/apache-site.erb",
					"templates/default/sites/<NAME>/wp-config.php.erb": "templates/default/wp-config.php.erb",
					"templates/default/sites/<NAME>/setup.sql.erb": "templates/default/setup.sql.erb"
				},
				"options": {}
			}
		}
	}

/***/ }
/******/ ]);