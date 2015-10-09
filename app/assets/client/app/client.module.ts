/// <reference path='../typings/tsd.d.ts' />
'use strict';

var valueModule = angular.module('powur.values', []);
var serviceModule = angular.module('powur.services', []);
var directiveModule = angular.module('powur.directives', []);
var filtersModule = angular.module('powur.filters', []);
var controllerModule = angular.module('powur.controllers', []);

var appModule = angular.module('powur', [
    'ui.router', 
    'templates',
    'ngMessages',
    'ngAnimate',
    'ngStorage',
    'ngMaterial',
    'powur.services', 
    'powur.directives',
    'powur.filters',
    'powur.controllers' 
]);

var $http: ng.IHttpService = angular.injector(['ng', 'powur']).get<ng.IHttpService>('$http');
var config = { headers: { 'X-Requested-With' : 'XMLHttpRequest' } };

$http.get('/', config).then(function(response: any) {
  angular.element(document).ready(function() {
    angular.module('powur').constant('sessionData', response.data);

    angular.bootstrap(document, ['powur']);
  });
});

