/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../../typings/references.d.ts' />

module powur.controllers {
    export interface IMarketingController {
        
    }
    
    class MarketingController implements IMarketingController {
        public static ControllerId: string = 'MarketingController'; 
        public static $inject: Array<string> = ['$log'];
        
        constructor(private $log: ng.ILogService) {
            var self = this;
            self.$log.debug(MarketingController.ControllerId + ':ctor');
        }        
    }
    
    controllerModule.controller(MarketingController.ControllerId, MarketingController);
}