/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../layout/auth.controller.ts' />

module powur {
  'use strict';

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

  angular
    .module('powur.invite')
    .controller(InviteController.ControllerId, InviteController);
}
