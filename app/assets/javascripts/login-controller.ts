/// <reference path='../typings/tsd.d.ts' />
/// <reference path='boot.ts' />
module powur.controllers {
    export interface ILoginController {
        
    }
    
    class LoginController implements ILoginController {
        public static ControllerId: string = 'LoginController'; 
        public static $inject: Array<string> = ['$log'];
        
        constructor(private $log: ng.ILogService) {
            var self = this;
            self.$log.debug(LoginController.ControllerId + ':ctor');
        }
        
        public user: any;
    }
    
    controllerModule.controller(LoginController.ControllerId, LoginController);
}