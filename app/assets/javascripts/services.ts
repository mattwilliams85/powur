/// <reference path='typings/tsd.d.ts' />
/// <reference path='init.ts' />
module powur.services {
	class AuthInterceptor {
		public static ServiceId: string = 'AuthInterceptor';	
		
		constructor(private $log: ng.ILogService, private $q: ng.IQService, private $location: ng.ILocationService) {
			var self = this;
			self.$log.debug(AuthInterceptor.ServiceId + ':ctor');
			return <any>{
				request: (config) => {
					return config || $q.when(config);
				},
				response: (reponse) => {
					return reponse || $q.when(reponse);
				},
				reponseError: (response) => {
					if (response.status === 401) {
						$location.path("/login");
					}
					return $q.reject(response);
				}	
			};
		}
		
		public user: any;
	}
	
	(<any>AuthInterceptor).$inject = ['$log'];
	serviceModule.factory(AuthInterceptor.ServiceId, AuthInterceptor);
}