/// <reference path='../typings/tsd.d.ts' />

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
        .state('login', {
          url: '/login',
          templateUrl: 'app/login/layout.html',
          controller: 'LoginController as loginLayout',
        }).state('login.public', {
          url: '/{resetCode}',
          templateUrl: 'app/login/login.public.html',
          controller: 'LoginPublicController as login',
        })
        .state('login.private', {
          templateUrl: 'app/login/login.private.html',
          controller: 'LoginPrivateController as login',
        })

        .state('join', {
          url: '/join',
          template: '<div ui-view></div>',
          abstract: true
        }).state('join.invalid', {
          url: '',
          templateUrl: 'app/join/invalid.html',
        }).state('join.grid', {
          url: '/grid/{inviteCode}',
          templateUrl: 'app/join/join-grid.html',
          controller: 'JoinGridController as join',
          resolve: {
            invite: function($stateParams, $q) {
              var root = RootController.get();
              var fail = function(response) {
                var reason: any = (response.status === 404) ? 'invalid_code' : response;
                return $q.reject(reason);
              }
              return root.$session.instance.getInvite($stateParams.inviteCode).then(null, fail);
            }
          }
        }).state('join.grid2', {
          url: '/grid',
          templateUrl: 'app/join/join-grid2.html',
          controller: 'JoinGridController as join',
          resolve: {
            invite: function($stateParams, $q) {
              var root = RootController.get();
              var fail = function(response) {
                var reason: any = (response.status === 404) ? 'invalid_code' : response;
                return $q.reject(reason);
              }
              return root.$session.instance.getInvite($stateParams.inviteCode).then(null, fail);
            }
          }
        }).state('join.solar', {
          url: '/solar/{inviteCode}',
          templateUrl: 'app/join/join-solar.html',
          controller: 'JoinSolarController as join',
          resolve: {
            customer: function($stateParams, $q) {
              var root = RootController.get();
              var fail = function(response) {
                var reason: any = (response.status === 404) ? 'invalid_code' : response;
                return $q.reject(reason);
              }
              return root.$session.instance.getCustomer($stateParams.inviteCode).then(null, fail);
            }
          }
        }).state('join.solar2', {
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
              return root.$session.instance.getCustomer($stateParams.inviteCode).then(null, fail);
            }
          }
        }).state('join.solar3', {
          url: '/solar',
          templateUrl: 'app/join/join-solar3.html'
        })

        .state('home', {
          abstract: true,
          templateUrl: 'app/home/home.html',
          controller: 'HomeController as home',
          resolve: {
            goals: function() {
              var root = RootController.get();
              return root.$session.instance.getEntity(GoalsModel, 'user-goals');
            },
            requirements: function(goals: GoalsModel) {
              return goals.getRequirements();
            }
          }
        }).state('home.invite', {
          url: '/invite',
          templateUrl: 'app/invite/layout.html',
          controller: 'InviteController as invite',
        }).state('home.invite.product', {
          url: '/solar',
          templateUrl: 'app/invite/invite.product.html',
          controller: 'InviteProductController as invite',
          resolve: {
            invites: function() {
              var root = RootController.get();
              return root.$session.instance.getEntity(SirenModel, 'user-product_invites');
            }
          }
        }).state('home.invite.grid', {
          url: '/grid',
          templateUrl: 'app/invite/invite.grid.html',
          controller: 'InviteGridController as invite',
          resolve: {
            invites: function() {
              var root = RootController.get();
              return root.$session.instance.getEntity(SirenModel, 'user-invites');
            }
          }
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
}
