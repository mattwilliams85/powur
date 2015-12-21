/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../services/session.service.ts' />

module powur {
  'use strict';

  function user(session: ISessionService, $stateParams: any) {
    return session.getRep($stateParams.repId);
  }

  function lead(session, $stateParams, $q) {
    if (!$stateParams.inviteCode) return;

    var root = RootController.get();
    var defer = $q.defer();
    session.getEntity(SirenModel, 'user-lead', { code: $stateParams.inviteCode })
      .then((response: ng.IHttpPromiseCallbackArg<any>) => {
        defer.resolve(response);
    }, () => {
      defer.resolve();
    });
    return defer.promise;
  }

  landingConfig.$inject = ['$stateProvider'];

  function landingConfig($stateProvider: ng.ui.IStateProvider) {
    $stateProvider
    .state('landing', {
        url: '/getsolar/{repId}/:inviteCode',
        templateUrl: 'app/landing/step1.html',
        controller: 'LandingController as landing',
        resolve: {
          rep: ['SessionService', '$stateParams', user],
          lead: ['SessionService', '$stateParams', '$q', lead]
        }
      })
    .state('landing-step2', {
        url: '/getsolar/step2/{repId}/:inviteCode',
        templateUrl: 'app/landing/step2.html',
        controller: 'LandingController as landing',
        resolve: {
          rep: ['SessionService', '$stateParams', user],
          lead: ['SessionService', '$stateParams', '$q', lead]
        }
      })
    .state('landing-thanks', {
        url: '/getsolar/thanks',
        templateUrl: 'app/landing/thanks.html',
        controller: 'LandingController as landing'
      });
  }

  angular
    .module('powur.landing', ['powur.core'])
    .config(landingConfig);
}
