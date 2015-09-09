/// <reference path='../typings/tsd.d.ts' />
/// <reference path='boot.ts' />
module powur.controllers {
	export interface IActivityController {
		
	}
	
	class ActivityController implements IActivityController {
		public static ControllerId: string = 'ActivityController';	
		
		constructor(private $log: ng.ILogService) {
			var self = this;
			self.$log.debug(ActivityController.ControllerId + ':ctor');
		}
	}
	
	(<any>ActivityController).$inject = ['$log'];
	controllerModule.controller(ActivityController.ControllerId, ActivityController);
}