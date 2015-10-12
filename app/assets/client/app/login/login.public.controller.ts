/// <reference path='../_references.ts' />

module powur {
  'use strict';

  class LoginPublicController extends BaseController {
    static ControllerId: string = 'LoginPublicController';
    static $inject = ['$mdDialog'];

    constructor(private $mdDialog: ng.material.IDialogService) {
      super();
    }

    get create(): Action {
      return this.session.instance.action('create');
    }

    get reset(): Action {
      return this.session.instance.action('reset_password');
    }

    cancel() {
      this.$mdDialog.cancel();
    }

    loginSubmit(): void {
      this.session.login().then((r: ng.IHttpPromiseCallbackArg<any>) => {
        this.state.go('login.private');
      });
    }
    
    showReset(e: MouseEvent): any {
      this.$mdDialog.show({
        controller: 'LoginPublicController as login',
        templateUrl: 'app/login/forgot-password.html',
        parent: angular.element(document.body),
        targetEvent: e,
        clickOutsideToClose: true
      })
    }
  }

  controllerModule.controller(LoginPublicController.ControllerId, LoginPublicController);
}