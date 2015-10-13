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

    get email(): Field {
      return this.create.field('email');
    }

    get password(): Field {
      return this.create.field('password');
    }

    get rememberMe(): Field {
      return this.create.field('remember_me');
    }

    cancel() {
      this.$mdDialog.cancel();
    }

    loginSubmit(): void {
      this.session.login().then((r: ng.IHttpPromiseCallbackArg<any>) => {
        this.state.go('home.invite');
      });
    }
    
    showReset(e: MouseEvent): ng.IPromise<any> {
      return this.$mdDialog.show({
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