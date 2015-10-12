/// <reference path='../_references.ts' />

module powur {
  'use strict';

  class LoginPublicController extends BaseController {
    static ControllerId: string = 'LoginPublicController';
    static $inject: Array<string> = ['$mdDialog'];

    constructor(private $mdDialog: ng.material.IDialogService) {
      super();
    }

    get create(): Action {
      return this.session.action('create');
    }

    get reset(): Action {
      return this.session.action('reset_password');
    }

    cancel() {
      this.$mdDialog.cancel();
    }

    resetSuccess = (response: ng.IHttpPromiseCallbackArg<any>): void => {
      this.root.$session.refresh().then((r: any) => {
        this.root.$state.go('login.private');
      });
    }

    loginSubmit(): void {
      this.root.$session.login().then((r: ng.IHttpPromiseCallbackArg<any>) => {
        this.root.$state.go('login.private');
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