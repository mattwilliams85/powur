/// <reference path='../../typings/references.d.ts' />

module powur {
    export interface ILoginController {
        
    }
    
    class LoginController implements ILoginController {
        public static ControllerId: string = 'LoginController'; 
        public static $inject: Array<string> = ['$log', '$state', 'CacheService'];
        
        public userName: string;
        public password: string;
        
        public errorMessage: string;
        
        constructor(private $log: ng.ILogService, private $state: ng.ui.IStateService, private cache: powur.services.ICacheService) {
            var self = this;
            self.$log.debug(LoginController.ControllerId + ':ctor');
            
            // test
            self.userName = 'test';
            self.password = 'test';
        }
        
        public login(): void {
            var self = this;
            self.errorMessage = null;
            
            if (self.isValidLogin()) {
                self.cache.user = { displayName: "Lyndia Portman" };
                self.$state.go('home', {}, {reload: true});
            } else {
                self.errorMessage = 'Please enter a valid login and password.';
            }
        }
        
        public hasError(): boolean {
            var self = this;
            return self.errorMessage != null && self.errorMessage != '';
        }
        
        private isValidLogin(): boolean {
            var self = this;
            return (self.userName == 'test') && (self.password == 'test');
        }
    }
    
    controllerModule.controller(LoginController.ControllerId, LoginController);
}