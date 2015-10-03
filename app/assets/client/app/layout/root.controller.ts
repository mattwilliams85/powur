/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../../typings/references.d.ts' />

module powur.controllers {    
    class RootController {
        public static ControllerId: string = 'RootController';
        public static $inject: Array<string> = ['$log', '$mdSidenav', '$state', 'CacheService'];
        
        constructor(private $log: ng.ILogService, private $mdSidenav: any, private $state: ng.ui.IStateService, private cache: powur.services.ICacheService) {
            var self = this;
            self.$log.debug(RootController.ControllerId + ':ctor');
            
            // TODO: write login check
            var isLogin = self.cache.user != null;
            
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
