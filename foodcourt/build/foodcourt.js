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
	var manifest = __webpack_require__(2);

	app.controller("stencilController", function ($scope) {
	  $scope.stencils = manifest.stencil_sets;
	  $scope.stencilsData = {};
	  for (var stencilName in manifest.stencil_sets) {
	    $scope.stencilsData[stencilName] = !(function webpackMissingModule() { var e = new Error("Cannot find module \"json!./../stencils\""); e.code = 'MODULE_NOT_FOUND'; throw e; }());
	  }

	  var stencilPacks = ["node", "wordpress"];
	  $scope.stencilPacks = {};
	  stencilPacks.forEach(function (stencilPackName) {
	    $scope.stencilPacks[stencilPackName] = !(function webpackMissingModule() { var e = new Error("Cannot find module \"json!./../test/test_sets\""); e.code = 'MODULE_NOT_FOUND'; throw e; }());
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

	function webpackContext(req) {
		throw new Error("Cannot find module '" + req + "'.");
	}
	webpackContext.keys = function() { return []; };
	webpackContext.resolve = webpackContext;
	module.exports = webpackContext;
	webpackContext.id = 1;


/***/ },
/* 2 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = {
		"api": 1,
		"framework": "chef",
		"stencil_sets": {},
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

/***/ }
/******/ ]);