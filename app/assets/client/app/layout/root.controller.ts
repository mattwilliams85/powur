/// <reference path='../_references.ts' />

module powur {
  export interface IRootController {
    session: ISessionModel;
    loggedIn: boolean;
    
    $log: ng.ILogService;
    $state: ng.ui.IStateService;
    cache: ICacheService;
    $session: ISessionService;
  }
  
  export class RootController implements IRootController {
    static ControllerId = 'RootController';
    static $inject = ['$log', '$mdSidenav', '$state', '$location', 'CacheService', 'SessionService'];
    
    static get(): IRootController {
        var root = angular.element('body').scope();
        return (<any>root).root;
    }

    //private _session: ISessionModel;
    
    constructor(public $log: ng.ILogService,
          private $mdSidenav: ng.material.ISidenavService,
          public $state: ng.ui.IStateService,
          private $location: ng.ILocationService,
          public cache: ICacheService,
          public $session: ISessionService) {
    }
    
    openMenu() {
      this.$mdSidenav('left').toggle();
    }

    get session(): ISessionModel {
      return this.$session.instance;
    }

    get loggedIn(): boolean {
      return this.session.loggedIn();
    }    
  }

  controllerModule.controller(RootController.ControllerId, RootController);
}
