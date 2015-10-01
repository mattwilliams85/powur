/// <reference path='../typings/tsd.d.ts' />
/// <reference path='../typings/references.d.ts' />

module powur.controllers {
    export interface IRootController {
        user: any;
    }
    
    class RootController implements IRootController {
        public static ControllerId: string = 'RootController';
        public static $inject: Array<string> = ['$log', '$mdSidenav'];
        
        public user: any;
        
        constructor(private $log: ng.ILogService, private $mdSidenav: any) {
            var self = this;
            self.$log.debug(RootController.ControllerId + ':ctor');
        }
        
        public openMenu() {
            var self = this;
            self.$mdSidenav('left')
            .toggle();
        }
    }
    
    controllerModule.controller(RootController.ControllerId, RootController);
}
