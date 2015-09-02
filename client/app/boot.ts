/// <reference path='../typings/tsd.d.ts' />
'use strict';

var controllerModule = angular.module('powur.controllers', []);
var serviceModule = angular.module('powur.services', []);
var valueModule = angular.module('powur.values', []);

var appModule = angular.module('powur', ['ui.router', 'powur.services', 'powur.controllers'])
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
			'stat': {},
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
			'stat': {},
			'main': {
				templateUrl: '/partials/login.html',
				controller: 'LoginController as login',
			},
			'activity': {},
		},
	})
	.state('strategy', {
		url: '/strategy',
		views: {
			'nav': {
				templateUrl: '/partials/nav.html',
				controller: 'NavController as nav',
			},
			'stat': {},
			'main': {},
			'activity': {},
		},
	})
	.state('events', {
		url: '/events',
		views: {
			'nav': {
				templateUrl: '/partials/nav.html',
				controller: 'NavController as nav',
			},
			'stat': {},
			'main': {},
			'activity': {},
		},
	})
	.state('grid', {
		url: '/grid',
		views: {
			'nav': {
				templateUrl: '/partials/nav.html',
				controller: 'NavController as nav',
			},
			'stat': {},
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
			'stat': {},
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
			'stat': {},
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
			'stat': {},
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
			'stat': {},
			'main': {},
			'activity': {},
		},
	});
	
}])
.run(['$rootScope', '$log', '$state', ($rootScope:  ng.IRootScopeService, $log: ng.ILogService, $state: ng.ui.IStateService) => {
	//TODO: login service
	// var isLoggedIn = true;
	
	// $rootScope.$on('$stateChangeStart', function (event, toState, toParams, fromState, fromParams) {
	// 	$log.debug('$stateChangeStart');
	// 	if (!isLoggedIn) {
	// 		event.preventDefault();
	// 		return $state.go('login');
	// 	}
	
	// 	return;
	// });

	$rootScope.$on('$stateChangeSuccess', (e, toState: ng.ui.IState, toParams: ng.ui.IStateParamsService, fromState: ng.ui.IState, fromParams: ng.ui.IStateParamsService) => {
		$log.debug('$stateChangeSuccess');
		if (fromState == null) {
			// first time
			$log.debug('first time');
		} else if (fromState.name == 'login') {
			// from login
			$log.debug('first login');
		} else if (toState.name == 'login') {
			// going to state
			$log.debug('going to state');
		}
	});
}]);