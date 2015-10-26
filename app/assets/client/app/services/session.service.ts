/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../models/session.model.ts' />

module powur {
  'use strict';

  export interface ISessionService extends ISessionModel {
    refresh(): ng.IPromise<any>;
    login(): ng.IPromise<ng.IHttpPromiseCallbackArg<any>>;
    logout(): ng.IPromise<ng.IHttpPromiseCallbackArg<any>>;
  }

  export class SessionService extends SessionModel implements ISessionService {
    static ServiceId = 'SessionService';
    static $inject = ['sessionData', '$http', '$q', '$state'];

    private executeAndRefresh(promise: ng.IPromise<ng.IHttpPromiseCallbackArg<any>>): ng.IPromise<ng.IHttpPromiseCallbackArg<any>> {
      var deferred = this.q.defer<ng.IHttpPromiseCallbackArg<any>>();
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

    constructor(sessionData: any,
                $http: ng.IHttpService,
                $q: ng.IQService,
                private $state: ng.ui.IStateService) {
      super(sessionData, $http, $q);
    }

    refresh(): ng.IPromise<any> {
      var afterGet = (response: ng.IHttpPromiseCallbackArg<any>) => {
        var data = response.data;
        angular.module('powur').constant('sessionData', data);
        this.refreshData(data);
      }
      return this.get().then(afterGet);
    }

    login(redirect = 'home.invite.grid', redirectParams?: any): ng.IPromise<ng.IHttpPromiseCallbackArg<any>> {
      var promise = this.executeAndRefresh(super.login());
      promise.then((r: ng.IHttpPromiseCallbackArg<any>) => {
        //(<any>this)._data.class = r.data.class;
        var data = r.data;
        angular.module('powur').constant('sessionData', data);
        this.refreshData(data);
        this.$state.go(redirect, redirectParams, { reload: true }); 
      });
      return promise;
    }

    logout(redirect = 'login.public', redirectParams?: any): ng.IPromise<ng.IHttpPromiseCallbackArg<any>> {
      var promise = this.executeAndRefresh(super.logout());
      promise.then((r: ng.IHttpPromiseCallbackArg<any>) => {
        this.$state.go(redirect, redirectParams);
      });
      return promise;
    }
  }

  angular
    .module('powur.services')
    .service(SessionService.ServiceId, SessionService);
}
