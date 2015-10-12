/// <reference path='../_references.ts' />

module powur {
  'use strict';

  export class BaseController {
//     static $inject = ['$log', '$state', 'SessionService'];
//     private _session: ISessionModel;
// 
//     get session(): ISessionModel {
//       return this.$session.instance;
//     }
// 
//     get loggedIn(): boolean {
//       return this.session.loggedIn();
//     }
// 
//     constructor(protected $log: ng.ILogService, public $state: ng.ui.IStateService, public $session: ISessionService) {
//       this.init();
//     }
// 
//     init(): void {}
    
    root: IRootController;

    constructor() {
      this.root = RootController.get();
    }
  }
}
