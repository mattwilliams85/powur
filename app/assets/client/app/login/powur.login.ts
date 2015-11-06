/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../services/session.service.ts' />

module powur {
  'use strict';

  function resetToken($stateParams, $q, session) {
    if (!$stateParams.resetCode) return;

    var fail = function(response) {
      var reason: any = (response.status === 404) ? 'invalid_password_token' : response;
      return $q.reject(reason);
    }

    return session
      .getPasswordToken($stateParams.resetCode)
      .then(null, fail);
  }

  loginConfig.$inject = ['$stateProvider'];

  function loginConfig($stateProvider: ng.ui.IStateProvider) {
    $stateProvider
      .state('login', {
        url: '/login',
        templateUrl: 'app/login/layout.html',
        controller: 'LoginController as loginLayout',
      })
      .state('login.public', {
        url: '/{resetCode}',
        templateUrl: 'app/login/login.public.html',
        controller: 'LoginPublicController as login',
        resolve: {
          resetToken: ['$stateParams', '$q', 'SessionService', resetToken]
        }
      })
      .state('login.private', {
        templateUrl: 'app/login/login.private.html',
        controller: 'LoginPrivateController as login',
        resolve: {
          resetToken: function() { }
        }
      });
  }

  angular
    .module('powur.login', ['powur.core'])
    .config(loginConfig);
}
