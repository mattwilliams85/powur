/// <reference path='../_references.ts' />

module powur {
  'use strict';

  export class BaseController {
    root: IRootController;

    get session(): ISessionService {
      return this.root.$session;
    }

    get loggedIn(): boolean {
      return this.session.instance.loggedIn();
    }

    get log(): ng.ILogService {
      return this.root.$log;
    }

    get state(): ng.ui.IStateService {
      return this.root.$state;
    }

    constructor() {
      this.root = RootController.get();
    }
  }
}
