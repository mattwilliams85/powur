/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../../typings/references.d.ts' />

module powur.controllers {
    export interface ILoginController {
        
    }
    
    class LoginController implements ILoginController {
        public static ControllerId: string = 'LoginController'; 
        public static $inject: Array<string> = ['$log', '$state', 'CacheService'];
        
        constructor(private $log: ng.ILogService, private $state: ng.ui.IStateService, private cache: powur.services.ICacheService) {
            var self = this;
            self.$log.debug(LoginController.ControllerId + ':ctor');
        }
        
        public login(): void {
            var self = this;
            self.cache.user = { displayName: "Lyndia Portman" };
            self.$state.go('home', {}, {reload: true});
        }
    }
    
    controllerModule.controller(LoginController.ControllerId, LoginController);
}