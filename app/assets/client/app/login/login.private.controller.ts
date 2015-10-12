/// <reference path='../_references.ts' />

module powur {
  'use strict';

  class LoginPrivateController extends BaseController {
    static ControllerId = 'LoginPrivateController';

    get logout(): Action {
      return this.session.action('logout');
    }

    logoutSubmit(): void {
      this.$session.logout().then((r: ng.IHttpPromiseCallbackArg<any>) => {
        this.$state.go('login.public');
      })
    }
  }

  controllerModule.controller(LoginPrivateController.ControllerId, LoginPrivateController);
}