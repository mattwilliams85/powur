/// <reference path='../_references.ts' />

module powur {
    class HomeController {
        static ControllerId: string = 'HomeController';
        static $inject: Array<string> = ['$log', '$state'];
        
        constructor(private $log: ng.ILogService, private $state: ng.ui.IStateService) {
            this.$log.debug(HomeController.ControllerId + ':ctor');
            this.$state.transitionTo('home.invite');
        }        
    }
    
    controllerModule.controller(HomeController.ControllerId, HomeController);
}