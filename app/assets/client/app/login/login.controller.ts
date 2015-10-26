/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../layout/base.controller.ts' />

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

  angular
    .module('powur.login')
    .controller(LoginController.ControllerId, LoginController);
}
