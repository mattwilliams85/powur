/// <reference path='../_references.ts' />

module powur {
  'use strict';

  export interface ISessionModel extends ISirenModel {
    loggedIn(): boolean;
    login(): ng.IPromise<ng.IHttpPromiseCallbackArg<any>>;
    logout(): ng.IPromise<ng.IHttpPromiseCallbackArg<any>>;
    getCustomer(code: string): ng.IPromise<ISirenModel>;
    getInvite(code: string): ng.IPromise<ISirenModel>;
  }

  export class SessionModel extends SirenModel implements ISessionModel {
    // private _q: ng.IQService;

    // get q(): ng.IQService {
    //   if (!this._q) {
    //     this._q = angular.element(document).injector().get('$q');
    //   }
    //   return this._q;
    // }

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

    getCustomer(code: string): ng.IPromise<ISirenModel> {
      return this.getEntity(SirenModel, 'customer-solar_invite', { code: code });
    }
    
    getInvite(code: string): ng.IPromise<ISirenModel> {
      return this.getEntity(SirenModel, 'solar_invite', { code: code });
    }
  }
}
