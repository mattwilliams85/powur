/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../services/session.service.ts' />

module powur {
  export interface IRootController {
    $log: ng.ILogService;
    $state: ng.ui.IStateService;
    $session: ISessionService;
    assets: any;
  }

  export class RootController implements IRootController {
    static ControllerId = 'RootController';
    static $inject = ['$log', '$state', 'SessionService', 'assets'];
    
    static get(): IRootController {
      var root = angular.element('body').scope();
      return (<any>root).root;
    }

    constructor(public $log: ng.ILogService,
                public $state: ng.ui.IStateService,
                public $session: ISessionService,
                public assets: any) {
    }
  }

  angular
    .module('powur.layout')
    .controller(RootController.ControllerId, RootController);
}
