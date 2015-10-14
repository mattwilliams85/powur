/// <reference path='../_references.ts' />

module powur {

  class InviteProductController extends AuthController {
    static ControllerId = 'InviteProductController';

    constructor() {
      super();
    }
  }

  controllerModule.controller(InviteProductController.ControllerId, InviteProductController);
}
