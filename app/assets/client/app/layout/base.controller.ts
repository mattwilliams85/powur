/// <reference path='../_references.ts' />

module powur {
  'use strict';

  export class BaseController {
    static $inject = ['$state', 'SessionService'];

    get session(): ISessionModel {
      return this.$session.session;
    }

    constructor(private $state: ng.ui.IStateService,
                private $session: ISessionService) {
    }
  }
}
