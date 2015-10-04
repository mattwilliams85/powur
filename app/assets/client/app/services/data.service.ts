/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../../typings/references.d.ts' />

module powur.services {    
    class DataService implements IDataService {
        public static ServiceId: string = 'DataService'; 
        public static $inject: Array<string> = ['$log'];
        
        constructor(private $log: ng.ILogService) {
            var self = this;
        }
        
        //angular-resource.js
        //ngResource
    }
    
    serviceModule.service(DataService.ServiceId, DataService);
}
