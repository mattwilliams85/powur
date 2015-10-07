/// <reference path='../_references.ts' />

module powur {
    export interface IJoinController {
        
    }
    
    class JoinController implements IJoinController {
        public static ControllerId: string = 'JoinController'; 
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
        
        constructor(private $log: ng.ILogService, private $state: ng.ui.IStateService, private $mdDialog: ng.material.IDialogService, private cache: ICacheService) {
            var self = this;
            self.$log.debug(JoinController.ControllerId + ':ctor');
            
            self.fullName = self.cache.user != null ? self.cache.user.displayName : "Anonymous";
        }
        
        public continue(): void {
            var self = this;
            self.$log.debug(JoinController.ControllerId + ':continue');
            self.$log.debug(self.gridKey);
            self.$state.go('join2', {});
        }
        
        public enterGrid(): void {
            var self = this;
            self.$log.debug(JoinController.ControllerId + ':enterGrid');
            self.$state.go('home', {});
        }
        
        public openTerms(ev: ng.IAngularEvent): void {
            var self = this;
            self.$mdDialog.show(<any>{
                controller: 'TermsDialogController as terms',
                templateUrl: 'app/join/terms.html',
                parent: angular.element(document.body),
                targetEvent: ev,
                clickOutsideToClose:true
            })
        }
    }
    
    controllerModule.controller(JoinController.ControllerId, JoinController);
}