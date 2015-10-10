/// <reference path='../_references.ts' />

module powur {
  'use strict';

  export interface ISessionService {
    session: ISessionModel;
    get(): ISessionModel;
    refresh(): ng.IPromise<any>;
  }

  export class SessionService implements ISessionService {
    static ServiceId = 'SessionService';
    static $inject = ['sessionData', '$http'];

    session: ISessionModel;

    constructor(private sessionData: any, private $http: ng.IHttpService) {
    }

    get(): ISessionModel {
      return new SessionModel(this.sessionData);
    }

    refresh(): ng.IPromise<any> {
      return this.$http.get('/').then((response: ng.IHttpPromiseCallbackArg<any>) => {
        this.sessionData = response.data;
        appModule.constant('sessionData', this.sessionData);
      });
    }
  }

  serviceModule.service(SessionService.ServiceId, SessionService);
}
