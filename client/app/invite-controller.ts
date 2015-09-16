/// <reference path='../typings/tsd.d.ts' />
/// <reference path='boot.ts' />
module powur.controllers {
    
    enum InvitationType {
        Advocate,
        Household
    }
    
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
    
    class InviteDialogController {
        public static ControllerId: string = 'InviteDialogController';
        public static $inject: Array<string> = ['$log', '$mdDialog'];
        
        public invitationType: InvitationType;
        public firstName: string;
        public lastName: string;
        public phone: string;
        public email: string;
        
        constructor(private $log: ng.ILogService, private $mdDialog: ng.material.IDialogService) {
            var self = this;
            
            //default
            self.invitationType = InvitationType.Advocate;
        }
        
        public cancel() {
            var self = this;
            self.$mdDialog.cancel();
        }
        
        public send() {
            var self = this;
            self.$mdDialog.hide({ 
                firstName: self.firstName,
                lastName: self.lastName,
                phone: self.phone,
                email: self.email,
            });
        }
    }
    
    controllerModule.controller(InviteDialogController.ControllerId, InviteDialogController);
    
    export interface IInviteController {
    }
    
    class InviteController implements IInviteController {
        public static ControllerId: string = 'InviteController';
        public static $inject: Array<string> = ['$log', '$interval', '$mdDialog'];
        
        public available: number;
        public pending: number;
        public accepted: number;
        public expired: number;
        
        public invites: Array<InviteItem>;
        
        public count: any;
        
        constructor(private $log: ng.ILogService, private $interval: ng.IIntervalService, private $mdDialog: ng.material.IDialogService) {
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
        
        public addInvite(item: InviteItem, e: MouseEvent) {
            var self = this;
             self.$mdDialog.show({
                controller: 'InviteDialogController as dialog',
                templateUrl: '/partials/invite-popup.html',
                //parent: angular.element(document.body),
                targetEvent: e,
                clickOutsideToClose: true
            })
            .then(function(data: any) {
                // ok
                self.$log.debug(data);
            }, function() {
                // cancel
                self.$log.debug('cancel');
            });
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
    
    controllerModule.controller(InviteController.ControllerId, InviteController);
}