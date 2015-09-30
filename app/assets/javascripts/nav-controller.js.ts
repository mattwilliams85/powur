/// <reference path='../typings/tsd.d.ts' />
declare var controllerModule: ng.IModule;

module powur.controllers {
    export interface INavController {
        
    }
    
    class NavController implements INavController {
        public static ControllerId: string = 'NavController';
        public static $inject: Array<string> = ['$log', '$state'];
        
        constructor(private $log: ng.ILogService, private $state: ng.ui.IStateService) {
            var self = this;
            self.$log.debug(NavController.ControllerId + ':ctor');

            //self.$log.debug(self.$state.$current);
            //self.$log.debug(self.$state.current);
        }
        
        public isCurrent(state: string): boolean {
            var self = this;
            return self.$state.current.name == state;
        }
        
        public go(state: string) {
            var self = this;
            self.$state.go(state);
        }
        
        public logout() {
            var self = this;
            self.$log.debug('logout');
            //TODO: kill session, logout, redirect to login
        }
    }
    
    controllerModule.controller(NavController.ControllerId, NavController);
}