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

var $http: ng.IHttpService = angular.injector(['ng']).get<ng.IHttpService>('$http');
var config: ng.IRequestShortcutConfig = { headers: { 'X-Requested-With' : 'XMLHttpRequest' } };

$http.get('/', config).then((response: ng.IHttpPromiseCallbackArg<any>) => {
  angular.element(document).ready(() => {
    appModule.constant('sessionData', response.data);

    angular.bootstrap(document, ['powur']);
  });
});

