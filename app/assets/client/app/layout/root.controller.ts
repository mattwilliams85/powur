/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../../typings/references.d.ts' />

module powur.controllers {
    export interface IRootController {
        user: any;
    }
    
    class RootController implements IRootController {
        public static ControllerId: string = 'RootController';
        public static $inject: Array<string> = ['$log', '$mdSidenav', '$state'];
        
        public user: any;
        
        constructor(private $log: ng.ILogService, private $mdSidenav: any, private $state: ng.ui.IStateService) {
            var self = this;
            self.$log.debug(RootController.ControllerId + ':ctor');
            
            // TODO: write login check
            var isLogin = true;
            
            if (isLogin) {
                self.$state.transitionTo('home');
            } else {
                self.$state.transitionTo('login');
            }
        }
        
        public openMenu() {
            var self = this;
            self.$mdSidenav('left')
            .toggle();
        }
    }
    
    controllerModule.controller(RootController.ControllerId, RootController);
}
