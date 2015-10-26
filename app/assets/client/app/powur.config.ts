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
        .state('join', {
          url: '/join',
          template: '<div ui-view></div>',
          abstract: true
        }).state('join.invalid', {
          url: '',
          templateUrl: 'app/join/invalid.html',
        })
        .state('join.grid', {
          url: '/grid/{inviteCode}',
          templateUrl: 'app/join/join-grid.html',
          controller: 'JoinGridController as join',
          data: {
            logout: true
          },
          resolve: {
            invite: function($stateParams, $q) {
              var root = RootController.get();
              var defer = $q.defer();
              root.$session.getInvite($stateParams.inviteCode).then((response: ng.IHttpPromiseCallbackArg<any>) => {
                defer.resolve(response);
              }, () => {
                defer.resolve({});
              });
              return defer.promise;
            }
          }
        })
        .state('join.grid2', {
          url: '/grid/{inviteCode}',
          templateUrl: 'app/join/join-grid2.html',
          controller: 'JoinGridController as join',
          resolve: {
            invite: function($stateParams, $q) {
              var root = RootController.get();
              var fail = function(response) {
                var reason: any = (response.status === 404) ? 'invalid_code' : response;
                return $q.reject(reason);
              }
              return root.$session.getInvite($stateParams.inviteCode).then(null, fail);
            }
          }
        })
        .state('join.solar', {
          url: '/solar/{inviteCode}',
          templateUrl: 'app/join/join-solar.html',
          controller: 'JoinSolarController as join',
          data: {
            logout: true
          },
          resolve: {
            customer: function($stateParams, $q) {
              var root = RootController.get();
              var defer = $q.defer();
              root.$session
                  .getCustomer($stateParams.inviteCode)
                  .then((response: ng.IHttpPromiseCallbackArg<any>) => {
                defer.resolve(response);
              }, () => {
                defer.resolve({});
              });
              return defer.promise;
            }
          }
        })
        .state('join.solar2', {
          url: '/solar/{inviteCode}',
          templateUrl: 'app/join/join-solar2.html',
          controller: 'JoinSolarController as join',
          params: {
            leadData: null
          },
          resolve: {
            customer: function($stateParams, $q) {
              var root = RootController.get();
              var fail = function(response) {
                var reason: any = (response.status === 404) ? 'invalid_code' : response;
                return $q.reject(reason);
              }
              return root.$session.getCustomer($stateParams.inviteCode).then(null, fail);
            }
          }
        })
        .state('join.solar3', {
          url: '/solar',
          templateUrl: 'app/join/join-solar3.html'
        })

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
