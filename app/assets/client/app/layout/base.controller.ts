/// <reference path='../_references.ts' />

module powur {
  'use strict';

  export class BaseController {
    root: IRootController;

    get session(): ISessionModel {
      return this.root.session;
    }

    get loggedIn(): boolean {
      return this.session.loggedIn();
    }

    constructor() {
      this.root = RootController.get();
    }
  }
}
