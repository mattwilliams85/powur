/// <reference path='../_references.ts' />

module powur {
  'use strict';

  class LoginPublicController extends BaseController {
    static ControllerId = 'LoginPublicController';

    constructor($state: ng.ui.IStateService, $session: ISessionService) {
      super($state, $session);

      this.create.success = this.loginSuccess;
    }

    get create(): Action {
      return this.session.action('create');
    }

    get email(): any {
      return this.create.field('email');
    }

    get password(): any {
      return this.create.field('password');
    }

    loginSuccess(response: ng.IHttpPromiseCallbackArg<any>) {
      this.$session.refresh().then((r: any) => {
        this.$state.go('login.private');
      });
    }
  }

  controllerModule.controller(LoginPublicController.ControllerId, LoginPublicController);
}