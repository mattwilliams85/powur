/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../../typings/references.d.ts' />

module powur.controllers {
    export interface IMarketingController {
        
    }
    
    class MarketingController implements IMarketingController {
        public static ControllerId: string = 'MarketingController'; 
        public static $inject: Array<string> = ['$log', 'CacheService'];
        
        public fullName: string;
        public gridKey: string;
        
        constructor(private $log: ng.ILogService, private cache: powur.services.ICacheService) {
            var self = this;
            self.$log.debug(MarketingController.ControllerId + ':ctor');
            
            self.fullName = self.cache.user != null ? self.cache.user.displayName : "Anonymous";
        }
        
        public continue() {
            var self = this;
            self.$log.debug(MarketingController.ControllerId + ':continue');
            self.$log.debug(self.gridKey);
        }    
    }
    
    controllerModule.controller(MarketingController.ControllerId, MarketingController);
}