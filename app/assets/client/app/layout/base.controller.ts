/// <reference path='../_references.ts' />

module powur {
  'use strict';

  export class BaseController {
    static $inject = ['$log', '$state', 'SessionService'];

    get session(): ISessionModel {
      return this.$session.instance;
    }

    get loggedIn(): boolean {
      return this.session.loggedIn();
    }

    constructor(protected $log: ng.ILogService,
                protected $state: ng.ui.IStateService,
                protected $session: ISessionService) {
      this.init();
    }

    init(): void {}
  }
}
