/// <reference path='../typings/tsd.d.ts' />
/// <reference path='boot.ts' />
module powur.controllers {
	
	enum InviteStatus {
		Pending,
		Available,
		Locked,
	}
	
	class InviteItem {
		name: string;
		time: Date;
		status: InviteStatus;
	}
	
	export interface IInviteController {
		
	}
	
	class InviteController implements IInviteController {
		public static ControllerId: string = 'InviteController';
		
		public available: number;
		public pending: number;
		public accepted: number;
		public expired: number;
		
		public invites: Array<InviteItem>;
		
		public count: any;
		
		constructor(private $log: ng.ILogService) {
			var self = this;
			self.$log.debug(InviteController.ControllerId + ':ctor');
			
			//sample data
			self.invites = [
				{ name: "John Baker", time: new Date(), status: InviteStatus.Pending, label: 11, percentage: 0.11 },
				{ name: "Melissa S", time: new Date(), status: InviteStatus.Pending, label: 11, percentage: 0.11 },
				{ name: null, time: null, status: InviteStatus.Available, label: 11, percentage: 0.11 },
				{ name: null, time: null, status: InviteStatus.Available, label: 11, percentage: 0.11 },
				{ name: null, time: null, status: InviteStatus.Available, label: 11, percentage: 0.11 },
				{ name: null, time: null, status: InviteStatus.Locked, label: 11, percentage: 0.11 },
				{ name: null, time: null, status: InviteStatus.Locked, label: 11, percentage: 0.11 },
				{ name: null, time: null, status: InviteStatus.Locked, label: 11, percentage: 0.11 },
				{ name: null, time: null, status: InviteStatus.Locked, label: 11, percentage: 0.11 },
				{ name: null, time: null, status: InviteStatus.Locked, label: 11, percentage: 0.11 },
				{ name: null, time: null, status: InviteStatus.Locked, label: 11, percentage: 0.11 },
				{ name: null, time: null, status: InviteStatus.Locked, label: 11, percentage: 0.11 },
			];
			
			self.available = 3;
			self.pending = 2;
			self.accepted = 0;
			self.expired = 0;
			
			self.count = { label: 11, percentage: 0.11 };
		}
		
		//TODO: convert to filter
		public getWhole(v: number): string {
			return this.toCommas(Math.floor(v));
		}
		
		public getDecimal(v: number): string {
			return (v % 1).toFixed(2).substring(2,4);
		}
		
		private toCommas(v: number): string {
		    return v.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
		}
	}
	
	(<any>InviteController).$inject = ['$log'];
	controllerModule.controller(InviteController.ControllerId, InviteController);
}