/// <reference path='../_references.ts' />

module powur {
  class AuthInterceptor {
    static ServiceId = 'AuthInterceptor'; 
    static $inject = ['$log', '$q'];
    
    constructor(private $log: ng.ILogService, 
                private $q: ng.IQService) {
      
      $log.debug('setting up interceptor');
      return <any>{
        request: (config: any) => {
          this.$log.debug(AuthInterceptor.ServiceId + ':request', config);

          return config || $q.when(config);
        },
        // 'response': (response: any) => {
        //   this.$log.debug(AuthInterceptor.ServiceId + ':response');
        //   return response || $q.when(response);
        // },

        responseError: (response: any) => {
          this.$log.debug(AuthInterceptor.ServiceId + ':responseError');
  
          if (response.status === 401) {
            //this.cache.clearAllSession();
            RootController.get().$session.logout().then((r: ng.IHttpPromiseCallbackArg<any>) => {
              RootController.get().$state.go('login.public');
            })            
            //this.$injector.invoke(($session: ISessionService) => {
              //$session.logout().then((r: ng.IHttpPromiseCallbackArg<any>) => {
                //this.$location.path('/');
              //})
            //})
          }
          
          return $q.reject(response);
        }
      };
    }
  }
  
  serviceModule.factory(AuthInterceptor.ServiceId, AuthInterceptor);
}
