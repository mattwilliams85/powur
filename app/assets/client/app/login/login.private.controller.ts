/// <reference path='../_references.ts' />

module powur {
  'use strict';

  class LoginPrivateController extends BaseController {
    static ControllerId = 'LoginPrivateController';
    static $inject = [];

    get logout(): Action {
      return this.session.action('logout');
    }

    logoutSubmit(): void {
      this.root.$session.logout().then((r: ng.IHttpPromiseCallbackArg<any>) => {
        this.root.$state.go('login.public');
      })
    }
  }

  controllerModule.controller(LoginPrivateController.ControllerId, LoginPrivateController);
}
