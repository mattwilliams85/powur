/// <reference path='../_references.ts' />

module powur {
    export interface ITermsDialogController {
        
    }
    
    class TermsDialogController implements ITermsDialogController {
        public static ControllerId: string = 'TermsDialogController'; 
        public static $inject: Array<string> = ['$log', '$mdDialog'];
        
        constructor(private $log: ng.ILogService, private $mdDialog: ng.material.IDialogService) {
            var self = this;
            self.$log.debug(TermsDialogController.ControllerId + ':ctor');            
        }
        
        public ok() {
            var self = this;
            self.$mdDialog.hide();
        }
    }
    
    controllerModule.controller(TermsDialogController.ControllerId, TermsDialogController);
}