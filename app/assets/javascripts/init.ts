/// <reference path='typings/tsd.d.ts' />
'use strict';

var controllerModule = angular.module('powur.controllers', []);
var serviceModule = angular.module('powur.services', []);

var appModule = angular.module('powur', ['ui.router', 'powur.services', 'powur.controllers'])
.config(['$stateProvider', '$urlRouterProvider', '$httpProvider', ($stateProvider: ng.ui.IStateProvider, $urlRouterProvider: ng.ui.IUrlRouterProvider, $httpProvider: ng.IHttpProvider) => {
	// check auth on api calls
	$httpProvider.interceptors.push('AuthInterceptor');

	// default for unknown
	$urlRouterProvider.otherwise('/');
	
	// routes
	$stateProvider.state('home', {
		url: '/',
		templateUrl: '/public/partials/home.html',
		controller: 'HomeController as home',
		//views: {} // named views
	})
}])
.run(['$rootScope', '$log', ($rootScope:  ng.IRootScopeService, $log: ng.ILogService) => {
	$rootScope.$on('$stateChangeSuccess', (e, toState: ng.ui.IState, toParams: ng.ui.IStateParamsService, fromState: ng.ui.IState, fromParams: ng.ui.IStateParamsService) => {
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
	})
}]);