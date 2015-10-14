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
      //$log.debug('stateChangeStart');
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
      //$log.debug('stateChangeSuccess');
    }
    
    var stateChangeError = (e: any,
                            toState: ng.ui.IState,
                            toParams: ng.ui.IStateParamsService,
                            fromState: ng.ui.IState,
                            fromParams: ng.ui.IStateParamsService,
                            error: any) => {
      //$log.debug('stateChangeError');
    }
  
      $rootScope.$on('$stateChangeStart', stateChangeStart);      
      $rootScope.$on('$stateChangeSuccess', stateChangeSuccess);
      $rootScope.$on('$stateChangeError', stateChangeError);
    }
    
  }
  
  appModule.run(RunConfigs);
}