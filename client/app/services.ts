/// <reference path='../typings/tsd.d.ts' />
/// <reference path='boot.ts' />
module powur.services {
    class AuthInterceptor {
        public static ServiceId: string = 'AuthInterceptor'; 
        public static $inject: Array<string> = ['$log', '$q', '$location'];   
        
        constructor(private $log: ng.ILogService, private $q: ng.IQService, private $location: ng.ILocationService) {
            var self = this;
            self.$log.debug(AuthInterceptor.ServiceId + ':ctor');
            return <any>{
                request: (config) => {
                    self.$log.debug(AuthInterceptor.ServiceId + ':request');
                    return config || $q.when(config);
                },
                response: (reponse) => {
                    self.$log.debug(AuthInterceptor.ServiceId + ':response');
                    return reponse || $q.when(reponse);
                },
                reponseError: (response) => {
                    self.$log.debug(AuthInterceptor.ServiceId + ':reponseError');
            
                    if (response.status === 401) {
                        $location.path("/login");
                    }
                    return $q.reject(response);
                }   
            };
        }
        
        public user: any;
    }
    
    serviceModule.factory(AuthInterceptor.ServiceId, AuthInterceptor);
}