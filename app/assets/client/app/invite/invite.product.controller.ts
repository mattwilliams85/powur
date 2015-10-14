/// <reference path='../_references.ts' />

module powur {

  class InviteProductController extends AuthController {
    static ControllerId = 'InviteProductController';
    static $inject = ['invites'];

    get list(): any[] {
      return this.invites.entities;
    }

    constructor(private invites: ISirenModel) {
      super();
      console.log('invites', invites);
    }
  }

  controllerModule.controller(InviteProductController.ControllerId, InviteProductController);
}
