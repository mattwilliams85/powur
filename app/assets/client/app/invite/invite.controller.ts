/// <reference path='../_references.ts' />

module powur {

  class InviteController extends AuthController {
    static ControllerId = 'InviteController';
  }

  controllerModule.controller(InviteController.ControllerId, InviteController);
}
