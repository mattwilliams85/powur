/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../services/session.service.ts' />

module powur {
  'use strict';

  landingConfig.$inject = ['$stateProvider'];

  function landingConfig($stateProvider: ng.ui.IStateProvider) {
    $stateProvider
    // Landing page
    .state('landing', {
        url: '/getsolar?rep_id',
        templateUrl: 'app/landing/step1.html',
        controller: 'LandingController as landing',
        resolve: {
          rep: function($stateParams, $q) {
            var root = RootController.get();
            var defer = $q.defer();
            root.$session
                .getRep($stateParams.rep_id)
                .then((response: ng.IHttpPromiseCallbackArg<any>) => {
              defer.resolve(response);
            }, () => {
              defer.resolve({});
            });
            return defer.promise;
          }
        }
      })
    .state('landing-step2', {
        url: '/getsolar/step2?rep_id',
        templateUrl: 'app/landing/step2.html',
        controller: 'LandingController as landing',
        resolve: {
          rep: function($stateParams, $q) {
            var root = RootController.get();
            var defer = $q.defer();
            root.$session
                .getRep($stateParams.rep_id)
                .then((response: ng.IHttpPromiseCallbackArg<any>) => {
              defer.resolve(response);
            }, () => {
              defer.resolve({});
            });
            return defer.promise;
          }
        }
      })
    .state('landing-thanks', {
        url: '/getsolar/thanks?rep_id',
        templateUrl: 'app/landing/thanks.html',
        controller: 'LandingController as landing',
        resolve: {
          rep: function($stateParams, $q) {
            var root = RootController.get();
            var defer = $q.defer();
            root.$session
                .getRep($stateParams.rep_id)
                .then((response: ng.IHttpPromiseCallbackArg<any>) => {
              defer.resolve(response);
            }, () => {
              defer.resolve({});
            });
            return defer.promise;
          }
        }
      });
  }

  angular
    .module('powur.landing', ['powur.core'])
    .config(landingConfig);
}
