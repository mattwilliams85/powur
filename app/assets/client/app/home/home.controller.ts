/// <reference path='../../typings/references.d.ts' />

module powur {
    export interface IHomeController {
        
    }
    
    class HomeController implements IHomeController {
        public static ControllerId: string = 'HomeController';  
        public static $inject: Array<string> = ['$log', '$state'];
        
        constructor(private $log: ng.ILogService, private $state: ng.ui.IStateService) {
            var self = this;
            self.$log.debug(HomeController.ControllerId + ':ctor');
            self.$state.transitionTo('home.invite');
        }        
    }
    
    controllerModule.controller(HomeController.ControllerId, HomeController);
}