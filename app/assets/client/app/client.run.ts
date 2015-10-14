/// <reference path='_references.ts' />

declare var appModule: ng.IModule;

module powur {
  class RunConfigs {
    static $inject = ['$rootScope', '$log', '$state', 'SessionService'];

    constructor($rootScope: ng.IRootScopeService,
                $log: ng.ILogService,
                $state: ng.ui.IStateService,
                $session: SessionService) {

      var stateChangeStart = (e: any, 
                              toState: ng.ui.IState,
                              toParams: ng.ui.IStateParamsService,
                              fromState: ng.ui.IState,
                              fromParams: ng.ui.IStateParamsService) => {

        if (/home\./.test(toState.name) && !$session.instance.loggedIn()){
          e.preventDefault();
          $state.go('login.private');
        }
      }
      
      var stateChangeSuccess = (e: any,
                                toState: ng.ui.IState,
                                toParams: ng.ui.IStateParamsService,
                                fromState: ng.ui.IState,
                                fromParams: ng.ui.IStateParamsService) => {
      }
      
      var stateChangeError = (e: any,
                              toState: ng.ui.IState,
                              toParams: ng.ui.IStateParamsService,
                              fromState: ng.ui.IState,
                              fromParams: ng.ui.IStateParamsService,
                              error: any) => {
        $log.debug('$stateChangeError', error);
        if (error === 'invalid_code') {
          $state.go('join.invalid');
        }
      }

      var stateNotFound = (e: any,
                           unfoundState: ng.ui.IState,
                           fromState: ng.ui.IState,
                           fromParams: ng.ui.IStateParamsService) => {
        $log.debug('not found', unfoundState);
      }

    
      $rootScope.$on('$stateChangeStart', stateChangeStart);
      $rootScope.$on('$stateChangeSuccess', stateChangeSuccess);
      $rootScope.$on('$stateChangeError', stateChangeError);
      $rootScope.$on('$stateNotFound', stateNotFound);
    }
    
  }
  
  appModule.run(RunConfigs);
}