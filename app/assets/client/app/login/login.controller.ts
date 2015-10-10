/// <reference path='../_references.ts' />

module powur {
  'use strict';

  class LoginController extends BaseController {
    static ControllerId = 'LoginController';

    get create(): Action {
      return this.session.action('create');
    }

    get childState(): string {
      return this.loggedIn ? 'login.private' : 'login.public';
    }

    init() {
      console.log('going to ' + this.childState);
      this.$state.go(this.childState);
    }
  }

  controllerModule.controller(LoginController.ControllerId, LoginController);
}