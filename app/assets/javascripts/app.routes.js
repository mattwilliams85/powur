;(function() {
  'use strict';

  angular
    .module('powurApp')
    .config(config);

  function config($routeProvider) {
    $routeProvider
      .otherwise({
        templateUrl: '/assets/angular/landing/templates/index.html',
        controller: 'HomeCtrl'
      });
  }
  
})();