/// <reference path='../typings/tsd.d.ts' />
declare var appModule: ng.IModule;

module powur {
  class RunConfigs {
    static $inject: Array<string> = ['$rootScope', '$log', '$state', '$urlMatcherFactory'];
    
    constructor($rootScope:  ng.IRootScopeService, $log: ng.ILogService, $state: ng.ui.IStateService, $urlMatcherFactoryProvider: ng.ui.IUrlMatcherFactory) {
      //TODO: login service
      // var isLoggedIn = true;
      
      //$urlMatcherFactoryProvider.caseInsensitive(true);
      //$urlMatcherFactoryProvider.strictMode(false);
      
      $rootScope.$on('$stateChangeStart', (e: ng.IAngularEvent, toState, toParams, fromState, fromParams) => {
      //  $log.debug('$stateChangeStart');
          // (<any>$state).to = toState;
          // (<any>$state).from = fromState;
      //  if (!isLoggedIn) {
      //      event.preventDefault();
      //      return $state.go('login');
      //  }
      
      //  return;
      });
  
      $rootScope.$on('$stateChangeSuccess', (e: ng.IAngularEvent, toState: ng.ui.IState, toParams: ng.ui.IStateParamsService, fromState: ng.ui.IState, fromParams: ng.ui.IStateParamsService) => {
        //$log.debug('$stateChangeSuccess');
        
        //save current
        //$state.current = toState;
        
        // if (fromState == null) {
        //  // first time
        //  $log.debug('first time');
        // } else if (fromState.name == 'login') {
        //  // from login
        //  $log.debug('first login');
        // } else if (toState.name == 'login') {
        //  // going to state
        //  $log.debug('going to state');
        // }
      });
    }
  }
  
  appModule.run(RunConfigs);
}