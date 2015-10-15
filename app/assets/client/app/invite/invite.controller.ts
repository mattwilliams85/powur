/// <reference path='../_references.ts' />

module powur {
  export class InviteItem {
    id: string;
    firstName: string;
    lastName: string;
    phone: string;
    email: string;
    expiresAt: Date;
    status: string;

    percentage: number;
  }

  export class NewInviteDialogController {
    static ControllerId = 'NewInviteDialogController';
    static $inject = ['$log', '$mdDialog'];

    constructor(private $log: ng.ILogService, public $mdDialog: ng.material.IDialogService) {
      // default
    }

    cancel() {
      this.$mdDialog.cancel();
    }

    send() {
      this.$mdDialog.hide();
    }
  }

  class InviteController extends AuthController {
    static ControllerId = 'InviteController';

    isCurrent(state: string): boolean {
      return this.state.current.name == state;
    }
  }

  controllerModule.controller(InviteController.ControllerId, InviteController);
}
