/// <reference path='siren.model.ts' />

module powur {
  'use strict';

  export interface ISessionModel extends ISirenModel {
    loggedIn(): boolean;
    login(): ng.IPromise<ng.IHttpPromiseCallbackArg<any>>;
    logout(): ng.IPromise<ng.IHttpPromiseCallbackArg<any>>;
    getRep(repId: number): ng.IPromise<ISirenModel>;
    getCustomer(code: string): ng.IPromise<ISirenModel>;
    getInvite(code: string): ng.IPromise<ISirenModel>;
    getPasswordToken(code: string): ng.IPromise<ISirenModel>;
  }

  export class SessionModel extends SirenModel implements ISessionModel {
    get(): ng.IHttpPromise<any> {
      return this.http.get('/');
    }

    loggedIn(): boolean {
      return this.hasClass('user');
    }

    login(): ng.IPromise<ng.IHttpPromiseCallbackArg<any>> {
      return this.action('create').submit();
    }

    logout(): ng.IPromise<ng.IHttpPromiseCallbackArg<any>> {
      this.removeClass('user');
      this.entities = [];
      return this.action('logout').submit();
    }

    getRep(rep_id: number): ng.IPromise<ISirenModel> {
      return this.getEntity(SirenModel, 'user-rep_invite', { rep_id: rep_id });
    }

    getCustomer(code: string): ng.IPromise<ISirenModel> {
      return this.getEntity(SirenModel, 'customer-solar_invite', { code: code });
    }

    getInvite(code: string): ng.IPromise<ISirenModel> {
      return this.getEntity(SirenModel, 'user-grid_invite', { code: code });
    }

    getPasswordToken(code: string): ng.IPromise<ISirenModel> {
      return this.getEntity(SirenModel, 'user-password_token', { code: code });
    }
  }
}
