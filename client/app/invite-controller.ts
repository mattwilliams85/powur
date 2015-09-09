/// <reference path='../typings/tsd.d.ts' />
/// <reference path='boot.ts' />
module powur.controllers {
	
	enum InviteStatus {
		Available,
		Pending,
		Accepted,
		Expired,
		Locked,
	}
	
	class InviteItem {
		firstName: string;
		lastName: string;
		time: Date;
		status: InviteStatus;
		
		percentage: number;
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
		
		constructor(private $log: ng.ILogService, private $interval: ng.IIntervalService) {
			var self = this;
			self.$log.debug(InviteController.ControllerId + ':ctor');
			
			//sample data
			self.invites = [
				{ firstName: "John", lastName: 'Baker', time: new Date(), status: InviteStatus.Pending, percentage: 0.11 },
				{ firstName: "Melissa", lastName: 'S.', time: new Date(), status: InviteStatus.Pending, percentage: 0.11 },
				{ firstName: null, lastName: null, time: null, status: InviteStatus.Available, percentage: 0.11 },
				{ firstName: null, lastName: null, time: null, status: InviteStatus.Available, percentage: 0.11 },
				{ firstName: null, lastName: null, time: null, status: InviteStatus.Available, percentage: 0.11 },
				{ firstName: null, lastName: null, time: null, status: InviteStatus.Locked, percentage: 0.11 },
				{ firstName: null, lastName: null, time: null, status: InviteStatus.Locked, percentage: 0.11 },
				{ firstName: null, lastName: null, time: null, status: InviteStatus.Locked, percentage: 0.11 },
				{ firstName: null, lastName: null, time: null, status: InviteStatus.Locked, percentage: 0.11 },
				{ firstName: null, lastName: null, time: null, status: InviteStatus.Locked, percentage: 0.11 },
				{ firstName: null, lastName: null, time: null, status: InviteStatus.Locked, percentage: 0.11 },
				{ firstName: null, lastName: null, time: null, status: InviteStatus.Locked, percentage: 0.11 },
			];
			
			var available = _.select(self.invites, function(c){    
				return c.status == InviteStatus.Available;
			});

			var pending = _.select(self.invites, function(c){    
				return c.status == InviteStatus.Pending;
			});

			var accepted = _.select(self.invites, function(c){    
				return c.status == InviteStatus.Accepted;
			});

			var expired = _.select(self.invites, function(c){    
				return c.status == InviteStatus.Expired;
			});
			
			self.available = available.length;
			self.pending = pending.length;
			self.accepted = accepted.length;
			self.expired = expired.length;
			
			self.$interval(() => {
				// progress
				self.invites[0].percentage = self.invites[0].percentage > 1 ? .2 : self.invites[0].percentage + .01;
				self.invites[1].percentage = self.invites[1].percentage > 1 ? 0 : self.invites[1].percentage + .02;

				// date
				self.invites[0].time = moment(self.invites[0].time).add(1, 's').toDate();
				self.invites[1].time = moment(self.invites[1].time).add(1, 's').toDate();
			}, 200, 0, true);
			
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
	
	(<any>InviteController).$inject = ['$log', '$interval'];
	controllerModule.controller(InviteController.ControllerId, InviteController);
}