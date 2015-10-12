/// <reference path='../_references.ts' />

module powur {
  'use strict';

  class LoginPublicController extends BaseController {
    static ControllerId: string = 'LoginPublicController';
    static $inject: Array<string> = BaseController.$inject.concat('$mdDialog');

    constructor($state: ng.ui.IStateService,
                $session: ISessionService,
                public $mdDialog: ng.material.IDialogService) {
      super($state, $session);
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
      this.$session.refresh().then((r: any) => {
        this.$state.go('login.private');
      });
    }

    loginSubmit(): void {
      this.$session.login().then((r: ng.IHttpPromiseCallbackArg<any>) => {
        this.$state.go('login.private');
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