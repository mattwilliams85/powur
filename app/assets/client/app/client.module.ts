/// <reference path='../typings/tsd.d.ts' />
'use strict';

var valueModule = angular.module('powur.values', []);
var serviceModule = angular.module('powur.services', []);
var directiveModule = angular.module('powur.directives', []);
var controllerModule = angular.module('powur.controllers', []);

var appModule = angular.module('powur', [
    'ui.router', 
    'powur.services', 
    'powur.directives', 
    'powur.controllers', 
    'ngMaterial', 
    'ui.calendar',
    'templates'
]);
