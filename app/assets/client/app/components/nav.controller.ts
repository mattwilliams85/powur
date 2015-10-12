/// <reference path='../_references.ts' />

module powur {
  class NavController {
    static ControllerId: string = 'NavController';
    static $inject: Array<string> = ['CacheService'];

    root: IRootController;
    
    constructor(private cache: ICacheService) {
      this.root = RootController.get();
      this.root.$log.debug(NavController.ControllerId + ':ctor');
    }
    
    isCurrent(state: string): boolean {
      return this.root.$state.current.name == state;
    }
    
    go(state: string) {
      this.root.$state.go(state);
    }
    
    logout() {
      this.cache.clearAllSession();
      this.root.$session.logout().then((r: ng.IHttpPromiseCallbackArg<any>) => {
        this.root.$state.go('login.public');
      })
    }
  }
  
  controllerModule.controller(NavController.ControllerId, NavController);
}