/// <reference path='../_references.ts' />

module powur {
  
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
    static ControllerId: string = 'InviteDialogController';
    static $inject: Array<string> = ['$log', '$mdDialog'];
    
    invitationType: InvitationType;
    firstName: string;
    lastName: string;
    phone: string;
    email: string;
    
    constructor(private $log: ng.ILogService, private $mdDialog: ng.material.IDialogService) {
      //default
      this.invitationType = InvitationType.Advocate;
    }
    
    cancel() {
      this.$mdDialog.cancel();
    }
    
    send() {
      this.$mdDialog.hide({ 
        firstName: this.firstName,
        lastName: this.lastName,
        phone: this.phone,
        email: this.email,
      });
    }
  }
  
  controllerModule.controller(InviteDialogController.ControllerId, InviteDialogController);
  
  class InviteController {
    static ControllerId: string = 'InviteController';
    static $inject: Array<string> = ['$log', '$interval', '$mdDialog'];
    
    available: number;
    pending: number;
    accepted: number;
    expired: number;
    
    timerColor: string;
    
    invites: Array<InviteItem>;
    
    count: any;
    
    constructor(private $log: ng.ILogService, private $interval: ng.IIntervalService, private $mdDialog: ng.material.IDialogService) {
      this.$log.debug(InviteController.ControllerId + ':ctor');
      
      //change color mode for advocate vs customer
      var isCustomer = true;
      this.timerColor = isCustomer ? '#2583a8' : '#ebb038';
      
      //sample data
      this.invites = [
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
      
      var available = _.select(this.invites, function(c){
        return c.status == InviteStatus.Available;
      });

      var pending = _.select(this.invites, function(c){
        return c.status == InviteStatus.Pending;
      });

      var accepted = _.select(this.invites, function(c){
        return c.status == InviteStatus.Accepted;
      });

      var expired = _.select(this.invites, function(c){
        return c.status == InviteStatus.Expired;
      });
      
      this.available = available.length;
      this.pending = pending.length;
      this.accepted = accepted.length;
      this.expired = expired.length;
      
      this.$interval(() => {
        // progress
        this.invites[0].percentage = this.invites[0].percentage > 1 ? .2 : this.invites[0].percentage + .01;
        this.invites[1].percentage = this.invites[1].percentage > 1 ? 0 : this.invites[1].percentage + .02;

        // date
        this.invites[0].time = moment(this.invites[0].time).add(1, 's').toDate();
        this.invites[1].time = moment(this.invites[1].time).add(1, 's').toDate();
      }, 200, 0, true);
    }
    
    addInvite(item: InviteItem, e: MouseEvent) {
      this.$mdDialog.show({
        controller: 'InviteDialogController as dialog',
        templateUrl: 'app/invite/invite-popup.html',
        parent: angular.element(document.body),
        targetEvent: e,
        clickOutsideToClose: true
      })
      .then((data: any) => {
        // ok
        this.$log.debug(data);
      }, () => {
        // cancel
        this.$log.debug('cancel');
      });
    }
  }
  
  controllerModule.controller(InviteController.ControllerId, InviteController);
}