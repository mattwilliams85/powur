/// <reference path='../_references.ts' />

module powur {

  class InviteProductController extends AuthController {
    static ControllerId = 'InviteProductController';
    static $inject = ['invites'];

    get list(): any[] {
      return this.invites.entities;
    }

    get listProps(): any {
      return this.invites.properties;
    }

    timerColor: string;

    constructor(private invites: ISirenModel) {
      super();
      var isCustomer = false;
      this.timerColor = isCustomer ? '#2583a8' : '#39ABA1';
    }
  }

  controllerModule.controller(InviteProductController.ControllerId, InviteProductController);
}
