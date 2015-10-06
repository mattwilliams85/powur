/// <reference path='../_references.ts' />

module powur {
    export interface IMarketingController {
        
    }
    
    class MarketingController implements IMarketingController {
        public static ControllerId: string = 'MarketingController'; 
        public static $inject: Array<string> = ['$log', '$state', '$mdDialog', 'CacheService'];
        
        //step 1
        public fullName: string;
        public gridKey: string;
        
        // step 2
        public firstName: string;
        public lastName: string;
        public address: string;
        public city: string;
        public state: string;
        public zip: string;
        
        public password: string;
        
        public states: Array<string>;
        
        constructor(private $log: ng.ILogService, private $state: ng.ui.IStateService, private $mdDialog: ng.material.IDialogService, private cache: ICacheService) {
            var self = this;
            self.$log.debug(MarketingController.ControllerId + ':ctor');
            
            self.fullName = self.cache.user != null ? self.cache.user.displayName : "Anonymous";
            
            self.states = ('AL AK AZ AR CA CO CT DE FL GA HI ID IL IN IA KS KY LA ME MD MA MI MN MS ' +
            'MO MT NE NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VT VA WA WV WI ' +
            'WY').split(' ');
        }
        
        public continue(): void {
            var self = this;
            self.$log.debug(MarketingController.ControllerId + ':continue');
            self.$log.debug(self.gridKey);
            self.$state.go('marketing2', {});
        }
        
        public enterGrid(): void {
            var self = this;
            self.$log.debug(MarketingController.ControllerId + ':enterGrid');
        }
        
        public openTerms(ev: ng.IAngularEvent): void {
            var self = this;
            self.$mdDialog.show(<any>{
                controller: 'TermsDialogController as terms',
                templateUrl: 'app/marketing/terms.html',
                parent: angular.element(document.body),
                targetEvent: ev,
                clickOutsideToClose:true
            })
        }
    }
    
    controllerModule.controller(MarketingController.ControllerId, MarketingController);
}