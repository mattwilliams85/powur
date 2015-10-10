/// <reference path='../_references.ts' />

module powur {
  'use strict';

  export class BaseController {
    static $inject = ['$state', 'SessionService'];
    private _session: ISessionModel;

    get session(): ISessionModel {
      return this._session;
    }

    get loggedIn(): boolean {
      return this.session.loggedIn();
    }

    constructor(public $state: ng.ui.IStateService,
                public $session: ISessionService) {
      this._session = $session.get();

      this.init();
    }

    init(): void {}
  }
}
