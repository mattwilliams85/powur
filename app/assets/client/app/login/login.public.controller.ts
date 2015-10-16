/// <reference path='../_references.ts' />

module powur {
  'use strict';
  class ResetDialogController extends BaseController {
    static ControllerId: string = 'ResetDialogController';
    static $inject = ['$mdDialog'];
    constructor(private $mdDialog: ng.material.IDialogService) {
      super();
    }

    cancel() {
      this.$mdDialog.cancel();
    }

    get reset(): Action {
      return this.session.instance.action('reset_password');
    }

    resetSubmit(): void {
      this.reset.submit().then((r: ng.IHttpPromiseCallbackArg<any>) => {
        this.cancel();
      });
    }
    
  }

  controllerModule.controller(ResetDialogController.ControllerId, ResetDialogController);

  class LoginPublicController extends BaseController {
    static ControllerId: string = 'LoginPublicController';
    static $inject = ['$mdDialog', '$stateParams', '$timeout'];
    private _create: Action;


    constructor(private $mdDialog: ng.material.IDialogService,
                private $stateParams: ng.ui.IStateParamsService,
                private $timeout: ng.ITimeoutService) {
      super();
      if (this.$stateParams['resetCode'])  {          
          this.showNewPassword();
      }
    }

    get create(): Action {
      if (!this._create) {
        this._create = this.session.instance.action('create');
      }
      return this._create;
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
        this.state.go('home.invite.grid');
      });
    }

    resetSubmit(): void {
      this.reset.submit().then((r: ng.IHttpPromiseCallbackArg<any>) => {
        this.cancel();
      });
    }
    
    showNewPassword(): ng.IPromise<any> {
      return this.$mdDialog.show({
        templateUrl: 'app/login/reset-password.html',
        controller: 'ResetDialogController as login',
        parent: angular.element(document.body),
        clickOutsideToClose: true,
        bindToController: true
      })
    }
    
    showReset(e: MouseEvent): ng.IPromise<any> {
      return this.$mdDialog.show({
        templateUrl: 'app/login/forgot-password.html',
        controller: 'LoginPublicController as login',
        parent: angular.element(document.body),
        targetEvent: e,
        clickOutsideToClose: true,
        bindToController: true
      })
    }


  }

  controllerModule.controller(LoginPublicController.ControllerId, LoginPublicController);
}