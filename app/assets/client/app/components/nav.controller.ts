/// <reference path='../_references.ts' />

module powur {
  class NavController {
    static ControllerId: string = 'NavController';
    static $inject: Array<string> = ['$log', '$state', 'CacheService'];
    
    constructor(private $log: ng.ILogService, private $state: ng.ui.IStateService, private cache: ICacheService) {
      this.$log.debug(NavController.ControllerId + ':ctor');

      //this.$log.debug(this.$state.$current);
      //this.$log.debug(this.$state.current);
    }
    
    isCurrent(state: string): boolean {
      return this.$state.current.name == state;
    }
    
    go(state: string) {
      this.$state.go(state);
    }
    
    logout() {
      this.cache.clearAllSession();
      this.$state.go('login', {}, {reload: true});
    }
  }
  
  controllerModule.controller(NavController.ControllerId, NavController);
}