/// <reference path='../typings/tsd.d.ts' />
'use strict';

var valueModule = angular.module('powur.values', []);
var serviceModule = angular.module('powur.services', []);
var directiveModule = angular.module('powur.directives', []);
var controllerModule = angular.module('powur.controllers', []);

var appModule = angular.module('powur', ['ui.router', 'powur.services', 'powur.directives', 'powur.controllers', 'ngMaterial', 'ui.calendar'])
.config(['$stateProvider', '$urlRouterProvider', '$httpProvider', ($stateProvider: ng.ui.IStateProvider, $urlRouterProvider: ng.ui.IUrlRouterProvider, $httpProvider: ng.IHttpProvider) => {
    // check auth on api calls
    $httpProvider.interceptors.push('AuthInterceptor');

    // default for unknown
    $urlRouterProvider.otherwise('/');
    
    // routes
    $stateProvider
    .state('home', {
        url: '/',
        views: {
            'nav': {
                templateUrl: '/partials/nav.html',
                controller: 'NavController as nav',
            },
            'profile': {
                templateUrl: '/partials/profile.html',
                controller: 'ProfileController as profile',
            },
            'main': {
                templateUrl: '/partials/home.html',
                controller: 'HomeController as home',
            },
            'activity': {},
        },
    })
    .state('login', {
        url: '/login',
        views: {
            'nav': {},
            'profile': {},
            'main': {
                templateUrl: '/partials/login.html',
                controller: 'LoginController as login',
            },
            'activity': {},
        },
    })
    .state('invite', {
        url: '/invite',
        views: {
            'nav': {
                templateUrl: '/partials/nav.html',
                controller: 'NavController as nav',
            },
            'profile': {
                templateUrl: '/partials/profile.html',
                controller: 'ProfileController as profile',
            },
            'main': {
                templateUrl: '/partials/invite.html',
                controller: 'InviteController as invite',
            },
            'activity': {
                templateUrl: '/partials/activity.html',
                controller: 'ActivityController as activity',
            },
        },
    })
    .state('events', {
        url: '/events',
        views: {
            'nav': {
                templateUrl: '/partials/nav.html',
                controller: 'NavController as nav',
            },
            'profile': {
                templateUrl: '/partials/profile.html',
                controller: 'ProfileController as profile',
            },
            'main': {
                templateUrl: '/partials/events.html',
                controller: 'EventsController as events',
            },
            'activity': {
                templateUrl: '/partials/activity.html',
                controller: 'ActivityController as activity',
            },
        },
    })
    .state('grid', {
        url: '/grid',
        views: {
            'nav': {
                templateUrl: '/partials/nav.html',
                controller: 'NavController as nav',
            },
            'profile': {
                templateUrl: '/partials/profile.html',
                controller: 'ProfileController as profile',
            },
            'main': {},
            'activity': {},
        },
    })
    .state('goal', {
        url: '/goal',
        views: {
            'nav': {
                templateUrl: '/partials/nav.html',
                controller: 'NavController as nav',
            },
            'profile': {
                templateUrl: '/partials/profile.html',
                controller: 'ProfileController as profile',
            },
            'main': {},
            'activity': {},
        },
    })
    .state('earnings', {
        url: '/earnings',
        views: {
            'nav': {
                templateUrl: '/partials/nav.html',
                controller: 'NavController as nav',
            },
            'profile': {
                templateUrl: '/partials/profile.html',
                controller: 'ProfileController as profile',
            },
            'main': {},
            'activity': {},
        },
    })
    //.state('social')
    .state('certs', {
        url: '/certs',
        views: {
            'nav': {
                templateUrl: '/partials/nav.html',
                controller: 'NavController as nav',
            },
            'profile': {
                templateUrl: '/partials/profile.html',
                controller: 'ProfileController as profile',
            },
            'main': {},
            'activity': {},
        },
    })
    .state('stats', {
        url: '/stats',
        views: {
            'nav': {
                templateUrl: '/partials/nav.html',
                controller: 'NavController as nav',
            },
            'profile': {
                templateUrl: '/partials/profile.html',
                controller: 'ProfileController as profile',
            },
            'main': {},
            'activity': {},
        },
    });
    
}])
.run(['$rootScope', '$log', '$state', ($rootScope:  ng.IRootScopeService, $log: ng.ILogService, $state: ng.ui.IStateService) => {
    //TODO: login service
    // var isLoggedIn = true;
    
    // $rootScope.$on('$stateChangeStart', function (event, toState, toParams, fromState, fromParams) {
    //  $log.debug('$stateChangeStart');
    //  if (!isLoggedIn) {
    //      event.preventDefault();
    //      return $state.go('login');
    //  }
    
    //  return;
    // });

    $rootScope.$on('$stateChangeSuccess', (e, toState: ng.ui.IState, toParams: ng.ui.IStateParamsService, fromState: ng.ui.IState, fromParams: ng.ui.IStateParamsService) => {
        $log.debug('$stateChangeSuccess');
        
        //save current
        $state.current = toState;
        
        // if (fromState == null) {
        //  // first time
        //  $log.debug('first time');
        // } else if (fromState.name == 'login') {
        //  // from login
        //  $log.debug('first login');
        // } else if (toState.name == 'login') {
        //  // going to state
        //  $log.debug('going to state');
        // }
    });
}]);