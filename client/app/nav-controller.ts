/// <reference path='../typings/tsd.d.ts' />
/// <reference path='boot.ts' />
module powur.controllers {
	export interface INavController {
		
	}
	
	class NavController implements INavController {
		public static ControllerId: string = 'NavController';	
		
		constructor(private $log: ng.ILogService) {
			var self = this;
			self.$log.debug(NavController.ControllerId + ':ctor');
		}
		
		public user: any;
	}
	
	(<any>NavController).$inject = ['$log'];
	controllerModule.controller(NavController.ControllerId, NavController);
}