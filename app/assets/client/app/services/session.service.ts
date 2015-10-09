/// <reference path='../_references.ts' />

module powur {
  'use strict';

  export interface ISessionService {
    session: ISessionModel;
  }

  export class SessionService implements ISessionService {
    static ServiceId = 'SessionService';
    static $inject = ['sessionData', '$http'];

    session: ISessionModel;

    constructor(private sessionData: any, private $http: ng.IHttpService) {
      SirenModel.http = $http;
      this.session = new SessionModel(sessionData);
    }
  }

  serviceModule.service(SessionService.ServiceId, SessionService);
}
