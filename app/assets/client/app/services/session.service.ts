/// <reference path='../_references.ts' />

module powur {
  'use strict';

  export interface ISessionService {
    instance: ISessionModel;
    refresh(): ng.IPromise<any>;
    login(): ng.IPromise<ng.IHttpPromiseCallbackArg<any>>;
    logout(): ng.IPromise<ng.IHttpPromiseCallbackArg<any>>;
  }

  export class SessionService implements ISessionService {
    static ServiceId = 'SessionService';
    static $inject = ['sessionData', '$http', '$q'];

    private _instance: ISessionModel;
    
    private executeAndRefresh(promise: ng.IPromise<ng.IHttpPromiseCallbackArg<any>>): ng.IPromise<ng.IHttpPromiseCallbackArg<any>> {
      var deferred = this.$q.defer<ng.IHttpPromiseCallbackArg<any>>();
      var success = (r: ng.IHttpPromiseCallbackArg<any>) => {
        this.refresh().then(() => {
          deferred.resolve(r);
        });
      }
      var fail = (r: ng.IHttpPromiseCallbackArg<any>) => {
        deferred.reject(r);
      }

      promise.then(success, fail);

      return deferred.promise;
    }

    get instance(): ISessionModel {
      if (!this._instance) {
        this._instance = new SessionModel(this.sessionData);
      }
      return this._instance;
    }

    constructor(private sessionData: any,
                private $http: ng.IHttpService,
                private $q: ng.IQService) {
    }

    refresh(): ng.IPromise<any> {
      var afterGet = (response: ng.IHttpPromiseCallbackArg<any>) => {
        this.sessionData = response.data;
        appModule.constant('sessionData', this.sessionData);
        this._instance = null;
      }
      return this.$http.get('/').then(afterGet);
    }

    login(): ng.IPromise<ng.IHttpPromiseCallbackArg<any>> {
      return this.executeAndRefresh(this.instance.login());
    }

    logout(): ng.IPromise<ng.IHttpPromiseCallbackArg<any>> {
      return this.executeAndRefresh(this.instance.logout());
    }
  }

  serviceModule.service(SessionService.ServiceId, SessionService);
}