/// <reference path='../_references.ts' />

module powur {
  class InviteProductItem {
    id: number;
    full_name: string;
    email: string;
    status: string;
  }

  class InviteProductController extends AuthController {
    static ControllerId = 'InviteProductController';

    available: number;
    pending: number;
    accepted: number;
    expired: number;

    timerColor: string;

    invites: Array<InviteItem>;

    count: any;

    constructor() {
      super();
      
      //change color mode for advocate vs customer
      var isCustomer = false;
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

      var available = _.select(this.invites, function(c) {
        return c.status == InviteStatus.Available;
      });

      var pending = _.select(this.invites, function(c) {
        return c.status == InviteStatus.Pending;
      });

      var accepted = _.select(this.invites, function(c) {
        return c.status == InviteStatus.Accepted;
      });

      var expired = _.select(this.invites, function(c) {
        return c.status == InviteStatus.Expired;
      });

      this.available = available.length;
      this.pending = pending.length;
      this.accepted = accepted.length;
      this.expired = expired.length;

      this.invites[0].percentage = this.invites[0].percentage > 1 ? .2 : this.invites[0].percentage + .01;
      this.invites[1].percentage = this.invites[1].percentage > 1 ? 0 : this.invites[1].percentage + .02;

      // date
      this.invites[0].time = moment(this.invites[0].time).add(1, 's').toDate();
      this.invites[1].time = moment(this.invites[1].time).add(1, 's').toDate();
      
    }
  }

  controllerModule.controller(InviteProductController.ControllerId, InviteProductController);
}
