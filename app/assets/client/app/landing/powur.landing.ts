/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../services/session.service.ts' />

module powur {
  'use strict';

  landingConfig.$inject = ['$stateProvider'];

  function landingConfig($stateProvider: ng.ui.IStateProvider) {
    $stateProvider
    // Landing page
    .state('landing', {
        url: '/getsolar',
        templateUrl: 'app/landing/step1.html',
        controller: 'LandingController as landing',
      })
    .state('landing-step2', {
        url: '/getsolar/step2',
        templateUrl: 'app/landing/step2.html',
        controller: 'LandingController as landing',
      })
    .state('landing-thanks', {
        url: '/getsolar/thanks',
        templateUrl: 'app/landing/thanks.html',
        controller: 'LandingController as landing',
      });
  }

  angular
    .module('powur.landing', ['powur.core'])
    .config(landingConfig);
}
