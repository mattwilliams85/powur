/// <reference path='../typings/tsd.d.ts' />
/// <reference path='boot.ts' />
module powur.controllers {
    export interface IRootController {
        user: any;
    }
    
    class RootController implements IRootController {
        public static ControllerId: string = 'RootController';  
        
        public user: any;
        
        constructor(private $log: ng.ILogService, private $mdSidenav) {
            var self = this;
            self.$log.debug(RootController.ControllerId + ':ctor');
        }
        
        public openMenu() {
            var self = this;
            self.$mdSidenav('left')
            .toggle();
        }
    }
    
    (<any>RootController).$inject = ['$log', '$mdSidenav'];
    controllerModule.controller(RootController.ControllerId, RootController);
}