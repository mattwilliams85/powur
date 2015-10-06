/// <reference path='../typings/tsd.d.ts' />
/// <reference path="models/siren.model.ts" />
'use strict';

var valueModule = angular.module('powur.values', []);
var serviceModule = angular.module('powur.services', []);
var directiveModule = angular.module('powur.directives', []);
var filtersModule = angular.module('powur.filters', []);
var controllerModule = angular.module('powur.controllers', []);

var appModule = angular.module('powur', [
    'ui.router', 
    'templates',
    'ngStorage',
    'ngMaterial',
    'powur.services', 
    'powur.directives',
    'powur.filters',
    'powur.controllers' 
]);
