/// <reference path='../_references.ts' />

module powur {
  'use strict';

  class LoginPrivateController extends BaseController {
    static ControllerId = 'LoginPrivateController';
    static $inject = [];

    get logout(): Action {
      return this.root.session.action('logout');
    }
    
    get $session(): ISessionService {
      return this.root.$session;
    }
    
    // constructor() {
    //   super();
    // }
    
    logoutSubmit(): void {
      this.root.$session.logout().then((r: ng.IHttpPromiseCallbackArg<any>) => {
        this.root.$state.go('login.public');
      })
    }
  }

  controllerModule.controller(LoginPrivateController.ControllerId, LoginPrivateController);
}