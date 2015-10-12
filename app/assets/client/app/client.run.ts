/// <reference path='_references.ts' />

declare var appModule: ng.IModule;

module powur {
  class RunConfigs {
    static $inject = ['$rootScope', '$log', '$state', 'SessionService'];

    constructor($rootScope: ng.IRootScopeService,
                $log: ng.ILogService,
                $state: ng.ui.IStateService,
                $session: SessionService) {

      $rootScope.$on('$stateChangeStart', stateChangeStart);

      function stateChangeStart(e: any,
                                toState: ng.ui.IState,
                                toParams: ng.ui.IStateParamsService,
                                fromState: ng.ui.IState,
                                fromParams: ng.ui.IStateParamsService) {

        if (/home\./.test(toState.name) && !$session.instance.loggedIn()) {
          e.preventDefault();
          $state.go('login.private');
        }
      }
      
      $rootScope.$on('$stateChangeSuccess', stateChangeSuccess);

      function stateChangeSuccess(e: any,
                                  toState: ng.ui.IState,
                                  toParams: ng.ui.IStateParamsService,
                                  fromState: ng.ui.IState,
                                  fromParams: ng.ui.IStateParamsService) {
      }

      $rootScope.$on('$stateChangeError', stateChangeError);

      function stateChangeError(e: any,
                                toState: ng.ui.IState,
                                toParams: ng.ui.IStateParamsService,
                                fromState: ng.ui.IState,
                                fromParams: ng.ui.IStateParamsService,
                                error: any) {
      }
    }
  }
  
  appModule.run(RunConfigs);
}