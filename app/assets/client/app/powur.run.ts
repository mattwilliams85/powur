/// <reference path='powur.module.ts' />
/// <reference path='services/session.service.ts' />

module powur {
  'use strict';

  export class RunConfigs {
    static $inject = ['$rootScope', '$log', '$state', 'SessionService'];

    constructor($rootScope: ng.IRootScopeService,
                $log: ng.ILogService,
                $state: ng.ui.IStateService,
                $session: SessionService) {

      $rootScope.$on('$stateChangeStart', stateChangeStart);
      $rootScope.$on('$stateChangeSuccess', stateChangeSuccess);
      $rootScope.$on('$stateChangeError', stateChangeError);
      $rootScope.$on('$stateNotFound', stateNotFound);

      function stateChangeStart(e: any,
                                toState: ng.ui.IState,
                                toParams: ng.ui.IStateParamsService,
                                fromState: ng.ui.IState,
                                fromParams: ng.ui.IStateParamsService) {

        if (toState.data && toState.data.logout && $session.loggedIn()) {
          e.preventDefault();
          $session.logout(toState.name, toParams);
        }

        if (/home\./.test(toState.name) && !$session.loggedIn()){
          e.preventDefault();
          $state.go('login.public');
        }
      }

      function stateChangeSuccess(e: any,
                                  toState: ng.ui.IState,
                                  toParams: ng.ui.IStateParamsService,
                                  fromState: ng.ui.IState,
                                  fromParams: ng.ui.IStateParamsService) {
      }

      function stateChangeError(e: any,
                                toState: ng.ui.IState,
                                toParams: ng.ui.IStateParamsService,
                                fromState: ng.ui.IState,
                                fromParams: ng.ui.IStateParamsService,
                                error: any) {

        $log.debug('$stateChangeError', error);

        if (typeof error === 'object') {
        }
        if (error === 'invalid_password_token') {
          $state.go('login');
        }
      }

      function stateNotFound(e: any,
                             unfoundState: ng.ui.IState,
                             fromState: ng.ui.IState,
                             fromParams: ng.ui.IStateParamsService) {
        $log.debug('not found', unfoundState);
      }
    }
  }

  angular.module('powur').run(RunConfigs);

  var $http: ng.IHttpService = angular.injector(['ng']).get<ng.IHttpService>('$http');
  var config: ng.IRequestShortcutConfig = { headers: { 'X-Requested-With': 'XMLHttpRequest' } };

  $http.get('/', config).then((response: ng.IHttpPromiseCallbackArg<any>) => {
    angular.element(document).ready(() => {
      angular.module('powur').constant('sessionData', response.data);

      angular.bootstrap(document, ['powur']);
    });
  });
}
