/// <reference path='../_references.ts' />

module powur {
    class JoinController {
        static ControllerId: string = 'JoinController'; 
        static $inject: Array<string> = ['$log', '$state', '$mdDialog', 'CacheService'];
        
        //step 1
        fullName: string;
        gridKey: string;
        zipKey: string;

        // step 2
        firstName: string;
        lastName: string;
        address: string;
        city: string;
        state: string;
        zip: string;
        
        password: string;
        
        constructor(private $log: ng.ILogService, private $state: ng.ui.IStateService, private $mdDialog: ng.material.IDialogService, private cache: ICacheService) {
            this.$log.debug(JoinController.ControllerId + ':ctor');
            
            this.fullName = this.cache.user != null ? this.cache.user.displayName : "Anonymous";
        }
        
        continue(state: string): void {
            var self = this;
            self.$log.debug(JoinController.ControllerId + ':continue');
            self.$log.debug(self.gridKey);
            self.$state.go(state, {});
        }
        
        enterGrid(): void {
            var self = this;
            self.$log.debug(JoinController.ControllerId + ':enterGrid');
            self.$state.go('home', {});
        }

        enterSolar(): void {
            var self = this;
            self.$log.debug(JoinController.ControllerId + ':enterGrid');
            self.$state.go('join.solar3', {});
        }
        
        openTerms(ev: ng.IAngularEvent): void {
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