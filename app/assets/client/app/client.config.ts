/// <reference path='../typings/tsd.d.ts' />
declare var appModule: ng.IModule;

module powur {
  class RouteConfigs {
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
          templateUrl: 'app/login/login.public.html',
          controller: 'LoginPublicController as login',
        })
        .state('login.private', {
          templateUrl: 'app/login/login.private.html',
          controller: 'LoginPrivateController as login',
        })

        .state('join', {
          url: '/join',
          template: '<div ui-view></div>'
        }).state('join.grid', {
          url: '/grid/{inviteCode}',
          templateUrl: 'app/join/join-grid.html',
          controller: 'JoinController as join',
        }).state('join.grid2', {
          url: '/grid',
          templateUrl: 'app/join/join-grid2.html',
          controller: 'JoinController as join',
          params: {
            inviteData: null
          }
        }).state('join.solar', {
          url: '/solar/{inviteCode}',
          templateUrl: 'app/join/join-solar.html',
          controller: 'JoinController as join',
        }).state('join.solar2', {
          url: '/solar',
          templateUrl: 'app/join/join-solar2.html',
          controller: 'JoinController as join',
          params: { 
            leadData: null 
          }
        }).state('join.solar3', {
          url: '/solar',
          templateUrl: 'app/join/join-solar3.html',
          controller: 'JoinController as join',
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
          abstract: true,
          templateUrl: 'app/invite/layout.html',
          controller: 'InviteController as invite',
        }).state('home.invite.product', {
          url: '/solar',
          templateUrl: 'app/invite/invite.product.html',
          controller: 'InviteProductController as invite',
          resolve: {

          }
        }).state('home.invite.grid', {
          url: '/grid',
          templateUrl: 'app/invite/invite.grid.html',
          controller: 'InviteGridController as invite',
          resolve: {

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

  appModule.config(RouteConfigs);
}
