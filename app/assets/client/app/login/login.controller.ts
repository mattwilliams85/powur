/// <reference path='../_references.ts' />

module powur {
  'use strict';

  class LoginController extends BaseController{
    static ControllerId = 'LoginController';
    static $inject = [];
    
    get create(): Action {
      return this.session.action('create');
    }

    get childState(): string {
      return this.loggedIn ? 'login.private' : 'login.public';
    }

    constructor() {
      super();
      this.root.$log.debug('going to ' + this.childState);
      this.root.$state.go(this.childState);
    }
  }

  controllerModule.controller(LoginController.ControllerId, LoginController);
}