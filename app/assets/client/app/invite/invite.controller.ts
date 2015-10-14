/// <reference path='../_references.ts' />

module powur {

  class InviteController extends AuthController {
    static ControllerId = 'InviteController';

    constructor() {
      super();

      this.log.debug('invite ctor: ');
    }
  }

  controllerModule.controller(InviteController.ControllerId, InviteController);
}
