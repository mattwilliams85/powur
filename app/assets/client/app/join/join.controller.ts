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
      this.$log.debug(JoinController.ControllerId + ':continue');
      this.$log.debug(this.gridKey);
      this.$state.go(state, {});
    }
    
    enterGrid(): void {
      this.$log.debug(JoinController.ControllerId + ':enterGrid');
      this.$state.go('home', {});
    }

    enterSolar(): void {
      this.$log.debug(JoinController.ControllerId + ':enterGrid');
      this.$state.go('join.solar3', {});
    }
    
    openTerms(ev: ng.IAngularEvent): void {
      this.$mdDialog.show(<any>{
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