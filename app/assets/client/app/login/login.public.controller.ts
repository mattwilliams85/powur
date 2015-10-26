/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../layout/base.controller.ts' />

module powur {
  'use strict';

  class ResetDialogController extends BaseController {
    static ControllerId: string = 'ResetDialogController';
    static $inject = ['$mdDialog', '$stateParams', 'resetToken'];

    constructor(private $mdDialog: ng.material.IDialogService,
                private $stateParams: ng.ui.IStateParamsService,
                private resetToken: ISirenModel) {
      super();

      this.reset.field('email').value = null;
      if (resetToken) this.updatePassword.field('token').value = $stateParams['resetCode'];
    }

    cancel() {
      this.$mdDialog.cancel();
    }

    get reset(): Action {
      return this.session.action('reset_password');
    }

    get updatePassword(): Action {
      return this.resetToken.action('update_password');
    }

    resetSubmit(): void {
      this.reset.submit().then((r: ng.IHttpPromiseCallbackArg<any>) => {
        this.cancel();
      });
    }

    updatePasswordSubmit(): void {
      this.updatePassword.submit().then((r: ng.IHttpPromiseCallbackArg<any>) => {
        this.cancel();
      });
    }
  }

  class LoginPublicController extends BaseController {
    static ControllerId: string = 'LoginPublicController';
    static $inject = ['$mdDialog', '$stateParams', 'resetToken'];
    private _create: Action;

    constructor(private $mdDialog: ng.material.IDialogService,
                private $stateParams: ng.ui.IStateParamsService,
                private resetToken: ISirenModel) {

      super();
      if (this.$stateParams['resetCode'])  {
        this.showNewPassword();
      }
    }

    get create(): Action {
      if (!this._create) {
        this._create = this.session.action('create');
      }
      return this._create;
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

    loginSubmit(): void {
      this.session.actions[0].fields = this.create.fields; // copy fields
      this.session.login();
    }

    showNewPassword(): ng.IPromise<any> {
      return this.$mdDialog.show({
        templateUrl: 'app/login/reset-password.html',
        controller: 'ResetDialogController as login',
        parent: angular.element(document.body),
        clickOutsideToClose: true,
        bindToController: true,
        locals: {
          resetToken: this.resetToken
        }
      })
    }

    showReset(e: MouseEvent): ng.IPromise<any> {
      return this.$mdDialog.show({
        templateUrl: 'app/login/forgot-password.html',
        controller: 'ResetDialogController as login',
        parent: angular.element(document.body),
        targetEvent: e,
        clickOutsideToClose: true,
        bindToController: true,
        locals: {
          resetToken: null
        }
      })
    }
  }

  angular
    .module('powur.login')
    .controller(ResetDialogController.ControllerId, ResetDialogController)
    .controller(LoginPublicController.ControllerId, LoginPublicController);
}
