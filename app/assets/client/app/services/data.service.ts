/// <reference path='../_references.ts' />

module powur {
    export interface IDataService {
        
    }
    
    export class DataService implements IDataService {
        static ServiceId: string = 'DataService'; 
        static $inject: Array<string> = ['$log'];
        
        constructor(private $log: ng.ILogService) {
            
        }
        
        //angular-resource.js
        //ngResource
    }
    
    serviceModule.service(DataService.ServiceId, DataService);
}
