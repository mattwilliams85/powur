/// <reference path='typings/tsd.d.ts' />
/// <reference path='init.ts' />
module powur.controllers {
	export interface IRootController {
		user: any;
	}
	
	class RootController implements IRootController {
		public static ControllerId: string = 'RootController';	
		
		constructor(private $log: ng.ILogService) {
			var self = this;
			self.$log.debug(RootController.ControllerId + ':ctor');
		}
		
		public user: any;
	}
	
	(<any>RootController).$inject = ['$log'];
	controllerModule.controller(RootController.ControllerId, RootController);
}