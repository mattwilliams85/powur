/// <reference path='../_references.ts' />

module powur {
  'use strict';

  class LoginPrivateController extends BaseController {
    static ControllerId = 'LoginPrivateController';

    get logout(): Action {
      return this.session.action('logout');
    }

    logoutSuccess = (response: ng.IHttpPromiseCallbackArg<any>): void => {
      this.$session.refresh().then((r: any) => {
        this.$state.go('login.public');
      });
    }

    constructor($state: ng.ui.IStateService, $session: ISessionService) {
      super($state, $session);

      this.logout.success = this.logoutSuccess;
    }
  }

  controllerModule.controller(LoginPrivateController.ControllerId, LoginPrivateController);
}