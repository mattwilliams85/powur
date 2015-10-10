/// <reference path='../_references.ts' />

module powur {
    class AuthInterceptor {
        static ServiceId: string = 'AuthInterceptor'; 
        static $inject: Array<string> = ['$log', '$q', '$location', 'CacheService'];
        
        constructor(private $log: ng.ILogService, private $q: ng.IQService, private $location: ng.ILocationService, private cache: ICacheService) {
            var self = this;
            self.$log.debug(AuthInterceptor.ServiceId + ':ctor');
            
            return <any>{
                request: (config: any) => {
                    self.$log.debug(AuthInterceptor.ServiceId + ':request');
                    return config || $q.when(config);
                },
                response: (response: any) => {
                    self.$log.debug(AuthInterceptor.ServiceId + ':response');
                    return response || $q.when(response);
                },
                reponseError: (response: any) => {
                    self.$log.debug(AuthInterceptor.ServiceId + ':reponseError');
            
                    if (response.status === 401) {
                        self.cache.clearAllSession();
                        $location.path("/");
                    }
                    
                    return $q.reject(response);
                }   
            };
        }
    }
    
    serviceModule.factory(AuthInterceptor.ServiceId, AuthInterceptor);
}
