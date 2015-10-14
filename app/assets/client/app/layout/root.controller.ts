/// <reference path='../_references.ts' />

module powur {
  export interface IRootController {
    $log: ng.ILogService;
    $state: ng.ui.IStateService;
    $session: ISessionService;
  }
  
  export class RootController implements IRootController {
    static ControllerId = 'RootController';
    static $inject = ['$log', '$state', 'SessionService'];
    
    static get(): IRootController {
      var root = angular.element('body').scope();
      return (<any>root).root;
    }

    constructor(public $log: ng.ILogService,
                public $state: ng.ui.IStateService,
                public $session: ISessionService) {
    }
  }

  controllerModule.controller(RootController.ControllerId, RootController);
}
