/// <reference path='../_references.ts' />

module powur {
  'use strict';

  class LoginController extends BaseController {
    static ControllerId = 'LoginController';
    static $inject = [];

    get childState(): string {
      return this.loggedIn ? 'home.invite' : 'login.public';
    }

    constructor() {
      super();
      this.state.go(this.childState);
    }
  }

  controllerModule.controller(LoginController.ControllerId, LoginController);
}
