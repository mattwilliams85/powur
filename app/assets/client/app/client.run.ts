/// <reference path='_references.ts' />

declare var appModule: ng.IModule;

module powur {
  class RunConfigs {
    static $inject = ['$rootScope', '$log', '$state'];

    // private $state: ng.ui.IStateService;
    // private stateChangeStart = (e: any,
    //                             toState: ng.ui.IState,
    //                             toParams: ng.ui.IStateParamsService,
    //                             fromState: ng.ui.IState,
    //                             fromParams: ng.ui.IStateParamsService) => {

    //   if (/home\./.test(toState.name)) {
    //       e.preventDefault();
    //       this.$state.go('login.private');
    //   }
    // }

    constructor($rootScope: ng.IRootScopeService,
                $log: ng.ILogService,
                $state: ng.ui.IStateService) {

      // console.log('foo', this);
      // this.$state = $state;

      // $rootScope.$on('$stateChangeStart', this.stateChangeStart);
      
      $rootScope.$on('$stateChangeStart',
                     (e: any,
                      toState: ng.ui.IState,
                      toParams: ng.ui.IStateParamsService,
                      fromState: ng.ui.IState,
                      fromParams: ng.ui.IStateParamsService) => {

        // if (/home\./.test(toState.name)) {
        //   console.log('s', $session)
        //   e.preventDefault();
        //   $state.go('login.private');
        // }
      });

      $rootScope.$on('$stateChangeSuccess',
                     (e: any,
                      toState: ng.ui.IState,
                      toParams: ng.ui.IStateParamsService,
                      fromState: ng.ui.IState,
                      fromParams: ng.ui.IStateParamsService) => {
      });

      $rootScope.$on('$stateChangeError',
                     (e: any,
                      toState: ng.ui.IState,
                      toParams: ng.ui.IStateParamsService,
                      fromState: ng.ui.IState,
                      fromParams: ng.ui.IStateParamsService,
                      error: any) => {
        console.log('error!', error)
      });
    }
  }
  
  appModule.run(RunConfigs);
}