/// <reference path='../typings/tsd.d.ts' />
/// <reference path='boot.ts' />
module powur.controllers {
	export interface IHomeController {
		
	}
	
	class HomeController implements IHomeController {
		public static ControllerId: string = 'HomeController';	
		
		constructor(private $log: ng.ILogService) {
			var self = this;
			self.$log.debug(HomeController.ControllerId + ':ctor');
		}
		
		public user: any;
	}
	
	(<any>HomeController).$inject = ['$log'];
	controllerModule.controller(HomeController.ControllerId, HomeController);
}