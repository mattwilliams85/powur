/// <reference path='../_references.ts' />

module powur {
  export interface IRootController {
    session: ISessionModel;
    loggedIn: boolean;
    
    $log: ng.ILogService;
    $state: ng.ui.IStateService;
    $session: ISessionService;
    cache: ICacheService;
  }
  
  export class RootController implements IRootController {
    static ControllerId = 'RootController';
    static $inject = ['$log', '$state', 'CacheService', 'SessionService'];
    
    static get(): IRootController {
        var root = angular.element('body').scope();
        return (<any>root).root;
    }

    //private _session: ISessionModel;
    
    constructor(public $log: ng.ILogService,
          public $state: ng.ui.IStateService,
          public cache: ICacheService,
          public $session: ISessionService) {
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
