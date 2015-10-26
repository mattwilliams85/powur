/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../layout/base.controller.ts' />

module powur {
  'use strict';

  class LoginPrivateController extends BaseController {
    static ControllerId = 'LoginPrivateController';
    static $inject = [];

    get logout(): Action {
      return this.session.action('logout');
    }

    logoutSubmit(): void {
      this.root.$session.logout();
    }
  }

  angular
    .module('powur.login')
    .controller(LoginPrivateController.ControllerId, LoginPrivateController);
}
