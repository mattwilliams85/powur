/// <reference path='powur.module.ts' />

module powur {
  'use strict';

  export class RouteConfigs {
    static $inject = ['$locationProvider', '$stateProvider', '$urlRouterProvider', '$httpProvider'];

    constructor($locationProvider: ng.ILocationProvider,
                $stateProvider: ng.ui.IStateProvider,
                $urlRouterProvider: ng.ui.IUrlRouterProvider,
                $httpProvider: ng.IHttpProvider) {

      $httpProvider.interceptors.push('AuthInterceptor');
      $httpProvider.defaults.headers.common['X-Requested-With'] = 'XMLHttpRequest';
      $httpProvider.defaults.xsrfHeaderName = 'X-CSRF-Token';

      $urlRouterProvider.when('/invite', '/invite/grid');
      $urlRouterProvider.otherwise('/login');

      $locationProvider.html5Mode(true);

      $stateProvider
        .state('home.events', {
          url: '/events',
          views: {
            'main': {
              templateUrl: 'app/events/events.html',
              controller: 'EventsController as events',
            }
          },
        });
    }
  }

  angular.module('powur').config(RouteConfigs);
}
