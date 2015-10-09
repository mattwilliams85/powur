/// <reference path='../_references.ts' />

module powur {
  'use strict';

  export interface ISessionModel extends ISirenModel {
    loggedIn(): boolean;
  }

  export class SessionModel extends SirenModel implements ISessionModel {
    constructor(data: any) {
      super(data);
    }

    loggedIn() : boolean {
      return this.hasClass('user');
    }
  }
}
