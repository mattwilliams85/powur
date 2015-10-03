/// <reference path='../typings/tsd.d.ts' />
/// <reference path='../typings/references.d.ts' />

module powur {
    class RunConfigs {
        public static $inject: Array<string> = ['$rootScope', '$log', '$state', '$urlMatcherFactory'];
        
        constructor($rootScope:  ng.IRootScopeService, $log: ng.ILogService, $state: ng.ui.IStateService, private $urlMatcherFactoryProvider: ng.ui.IUrlMatcherFactory) {
            //TODO: login service
            // var isLoggedIn = true;
            
            //$urlMatcherFactoryProvider.caseInsensitive(true);
            //$urlMatcherFactoryProvider.strictMode(false);
            
            $rootScope.$on('$stateChangeStart', function (event, toState, toParams, fromState, fromParams) {
            //  $log.debug('$stateChangeStart');
                (<any>$state).to = toState;
                (<any>$state).from = fromState;
            //  if (!isLoggedIn) {
            //      event.preventDefault();
            //      return $state.go('login');
            //  }
            
            //  return;
            });
        
            $rootScope.$on('$stateChangeSuccess', (e: any, toState: ng.ui.IState, toParams: ng.ui.IStateParamsService, fromState: ng.ui.IState, fromParams: ng.ui.IStateParamsService) => {
                $log.debug('$stateChangeSuccess');
                
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