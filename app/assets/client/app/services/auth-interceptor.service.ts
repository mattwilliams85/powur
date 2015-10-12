/// <reference path='../_references.ts' />

module powur {
  class AuthInterceptor {
    static ServiceId = 'AuthInterceptor'; 
    static $inject = ['$log', '$q', '$location', '$injector'];
    
    constructor(private $log: ng.ILogService, 
                private $q: ng.IQService,
                private $location: ng.ILocationService,
                private $injector: ng.auto.IInjectorService) {
      
      $log.debug('setting up interceptor');
      return <any>{
        // 'request': (config: any) => {
        //   this.$log.debug(AuthInterceptor.ServiceId + ':request', config);

        //   return config || $q.when(config);
        // },
        // 'response': (response: any) => {
        //   this.$log.debug(AuthInterceptor.ServiceId + ':response');
        //   return response || $q.when(response);
        // },

        'reponseError': (response: any) => {
          this.$log.debug(AuthInterceptor.ServiceId + ':reponseError');
  
          // if (response.status === 401) {
          //   this.$injector.invoke(($session: ISessionService) => {
          //     $session.logout().then((r: ng.IHttpPromiseCallbackArg<any>) => {
          //       this.$location.path('/');
          //     })
          //   })
          // }
          
          return $q.reject(response);
        }
      };
    }
  }
  
  serviceModule.factory(AuthInterceptor.ServiceId, AuthInterceptor);
}
