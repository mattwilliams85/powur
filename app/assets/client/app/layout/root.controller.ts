/// <reference path='../_references.ts' />

module powur {
  class RootController {
    static ControllerId = 'RootController';
    static $inject = ['$log', '$mdSidenav', '$state', '$location', 'CacheService', 'SessionService'];

    private session: ISessionModel;
    
    constructor(private $log: ng.ILogService,
          private $mdSidenav: any,
          private $state: ng.ui.IStateService,
          private $location: ng.ILocationService,
          private cache: ICacheService,
          private $session: ISessionService) {
    }
    
    openMenu() {
      this.$mdSidenav('left').toggle();
    }
    
  }

  controllerModule.controller(RootController.ControllerId, RootController);
}
