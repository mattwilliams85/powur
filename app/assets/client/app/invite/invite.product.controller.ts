/// <reference path='../_references.ts' />

module powur {
  class InviteProductItem {
    id: number;
    full_name: string;
    email: string;
    status: string;
  }

  class InviteProductController extends AuthController {
    static ControllerId = 'InviteProductController';

    constructor() {
      super();
    }
  }

  controllerModule.controller(InviteProductController.ControllerId, InviteProductController);
}
