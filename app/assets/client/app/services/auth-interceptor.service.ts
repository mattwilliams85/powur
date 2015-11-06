/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='session.service.ts' />

module powur {

  class AuthInterceptor implements ng.IHttpInterceptor {
    static ServiceId = 'AuthInterceptor';
    static $inject = ['$injector', '$log', '$q'];

    private getSession(): ISessionService {
      return this.$injector.get<ISessionService>('SessionService');
    }

    constructor(private $injector: ng.auto.IInjectorService,
                private $log: ng.ILogService,
                private $q: ng.IQService) {
    }

    logout(): void {
      var session = this.getSession();
      session.logout();
    }

    request = (config: ng.IRequestConfig): ng.IRequestConfig => {
      // this.$log.debug('sending request', config);
      return config;
    }

    response = (response: ng.IHttpPromiseCallbackArg<any>): ng.IPromise<any>|any => {
      // this.$log.debug('received response', response);
      return response;
    }

    responseError = (rejection: any) => {
      switch (rejection.status) {
        case 401:
        case 419:
          this.logout();
          break;
      }

      return this.$q.reject(rejection);
    }

  }

  angular
    .module('powur.services')
    .service(AuthInterceptor.ServiceId, AuthInterceptor);
}
