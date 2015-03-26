/* global angular */
'use strict';

const app = angular.module('foodcourt', []);
const manifest = require('json!./../manifest.json');

app.controller('stencilController', function ($scope) {
  $scope.stencils = manifest.stencil_sets;
  $scope.stencilsData = {};
  for (let stencilName in manifest.stencil_sets) {
    $scope.stencilsData[stencilName] = require('json!./../stencils/' + stencilName + '/manifest.json');
  }

  let stencilPacks = [ 'node', 'wordpress' ];
  $scope.stencilPacks = {};
  stencilPacks.forEach(function (stencilPackName) {
    $scope.stencilPacks[stencilPackName] = require('json!./../test/test_sets/' + stencilPackName + '.json');
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
    let stencils = $scope.stencilPacks[name].stencils;
    for (let stencil in stencils) {
      delete stencils[stencil].$$hashKey;
    }
    $scope.selectedStencils = {};
    $scope.numStencils = 0;
    $scope.manifest_output = $scope.prettyJson({
      name: 'My_new_cookbook',
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
      return '';
    }
    return Object.keys(input).join(', ');
  };

  $scope.buildManifest = function () {
    let output = {
      name: 'My_new_cookbook',
      stencils: []
    };
    for (let name in $scope.selectedStencils) {
      let stencil = $scope.selectedStencils[name];
      let obj = {
        stencil_set: name
      };
      for (let optName in stencil.options) {
        let option = stencil.options[optName];
        if (option.choice !== undefined) {
          obj[optName] = option.choice;
        }
      }
      output.stencils.push(obj);
    }
    $scope.manifest_output = $scope.prettyJson(output);
  };

});
