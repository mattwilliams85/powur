;
(function() {
  'use strict';

  function config($locationProvider, $stateProvider, $urlRouterProvider, $httpProvider, $provide, siren) {

    $locationProvider.html5Mode(true);

    $provide.factory('sirenInterceptor', siren.interceptor);

    $httpProvider.defaults.xsrfHeaderName = 'X-CSRF-Token';
    $httpProvider.defaults.headers.common["X-Requested-With"] = 'XMLHttpRequest';
    $httpProvider.interceptors.push('sirenInterceptor');

    $urlRouterProvider.otherwise('/');

    $stateProvider
      .state('home', {
        url: '/',
        templateUrl: '/assets/home/index.html',
        security: 'anon'
      })
  }

  config.$inject = [
    '$locationProvider',
    '$stateProvider',
    '$urlRouterProvider',
    '$httpProvider',
    '$provide',
    'siren'
  ];

  angular.module('powurApp').config(config);

})();