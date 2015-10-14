/// <reference path='../_references.ts' />

module powur {

  class InviteController extends AuthController {
    static ControllerId = 'InviteController';

    constructor() {
      super();

      this.log.debug('invite ctor: ');
    }
    
    isCurrent(state: string): boolean {
      return this.state.current.name == state;
    }
  }

  controllerModule.controller(InviteController.ControllerId, InviteController);
}
