/// <reference path='../_references.ts' />

module powur {
  'use strict';

  export interface ISessionModel extends ISirenModel {
    loggedIn(): boolean;
    login(): ng.IPromise<ng.IHttpPromiseCallbackArg<any>>;
    logout(): ng.IPromise<ng.IHttpPromiseCallbackArg<any>>;
  }

  export class SessionModel extends SirenModel implements ISessionModel {
    constructor(data: any) {
      super(data);
    }

    loggedIn(): boolean {
      return this.hasClass('user');
    }

    login(): ng.IPromise<ng.IHttpPromiseCallbackArg<any>> {
      return this.action('create').submit();
    }

    logout(): ng.IPromise<ng.IHttpPromiseCallbackArg<any>> {
      return this.action('logout').submit();
    }
  }
}
