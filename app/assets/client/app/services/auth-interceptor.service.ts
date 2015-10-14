/// <reference path='../_references.ts' />

module powur {
  class AuthInterceptor {
    static ServiceId = 'AuthInterceptor'; 
    static $inject = ['$log', '$q'];
    
    constructor(private $log: ng.ILogService, private $q: ng.IQService) {      
      var logout = () => {
        RootController.get().$session.logout().then((r: ng.IHttpPromiseCallbackArg<any>) => {
          RootController.get().$state.go('login.public');
        })            
      };
      
      var notAuthenticated = () => {
        logout();
      };
      
      var notAuthorized = () => {
        alert('not authorized');
      };
      
      var sessionTimeout = () => {
        logout();
      };
      
      var internalServer = () => {
        $log.debug('internal server error');
      };
      
      return <any>{
        // request: (config: any) => {
        //   this.$log.debug(AuthInterceptor.ServiceId + ':request', config);
        //   return config || $q.when(config);
        // },
        // 'response': (response: any) => {
        //   this.$log.debug(AuthInterceptor.ServiceId + ':response');
        //   return response || $q.when(response);
        // },

        responseError: (response: any) => {
          //this.$log.debug(AuthInterceptor.ServiceId + ':responseError');
  
          switch(response.status) {
            case 401: notAuthenticated(); break;
            case 403: notAuthorized(); break;
            case 419: sessionTimeout(); break;
            case 500: internalServer(); break;
            // default: $log.debug('re: ', response);
          }
          
          return $q.reject(response);
        }
      };
    }
  }
  
  serviceModule.factory(AuthInterceptor.ServiceId, AuthInterceptor);
}
