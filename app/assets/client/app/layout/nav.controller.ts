/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../../typings/references.d.ts' />

module powur.controllers {
    export interface INavController {
        
    }
    
    class NavController implements INavController {
        public static ControllerId: string = 'NavController';
        public static $inject: Array<string> = ['$log', '$state', 'CacheService'];
        
        constructor(private $log: ng.ILogService, private $state: ng.ui.IStateService, private cache: powur.services.ICacheService) {
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
            self.cache.clearAllSession();
            self.$state.go('login', {}, {reload: true});
        }
    }
    
    controllerModule.controller(NavController.ControllerId, NavController);
}