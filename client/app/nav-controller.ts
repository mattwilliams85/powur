/// <reference path='../typings/tsd.d.ts' />
/// <reference path='boot.ts' />
module powur.controllers {
	export interface INavController {
		
	}
	
	class NavController implements INavController {
		public static ControllerId: string = 'NavController';	
		
		constructor(private $log: ng.ILogService, private $state: ng.ui.IStateService) {
			var self = this;
			self.$log.debug(NavController.ControllerId + ':ctor');
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
	
	(<any>NavController).$inject = ['$log', '$state'];
	controllerModule.controller(NavController.ControllerId, NavController);
}