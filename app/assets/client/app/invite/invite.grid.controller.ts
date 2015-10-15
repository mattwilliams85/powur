/// <reference path='../_references.ts' />

module powur {
  export class InviteItem {
    id: string;
    firstName: string;
    lastName: string;
    phone: string;
    email: string;
    expiresAt: Date;
    status: string;

    percentage: number;
  }

  class InviteDialogController {
    static ControllerId = 'InviteDialogController';
    static $inject = ['$log', '$mdDialog'];

    invitationType: string;
    firstName: string;
    lastName: string;
    phone: string;
    email: string;

    constructor(private $log: ng.ILogService, private $mdDialog: ng.material.IDialogService) {
      // default
      // this.invitationType = InvitationType.Advocate;
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

  class InviteGridController extends AuthController {
    static ControllerId = 'InviteGridController';
    static $inject = ['invites', '$mdDialog'];

    available: number;
    pending: number;
    accepted: number;
    expired: number;

    timerColor: string;

    inviteEntities: Array<InviteItem>;
    // count: any;

    constructor(private invites: ISirenModel,
                public $mdDialog: ng.material.IDialogService) {
      super();

      // change color mode for advocate vs customer
      var isCustomer = true;
      this.timerColor = isCustomer ? '#2583a8' : '#ebb038';

      this.inviteEntities = [];
      _.each(this.invites.entities, (invite) => {
        this.inviteEntities.push({
          id: invite['properties'].id,
          firstName: invite['properties'].first_name,
          lastName: invite['properties'].last_name,
          phone: invite['properties'].phone,
          email: invite['properties'].email,
          expiresAt: new Date(invite['properties'].expires_at),
          status: invite['properties'].status,
          percentage: 0.11
        })
      });

      var pending = _.select(this.inviteEntities, function(invite) {
        return invite.status === 'valid';
      });

      var accepted = _.select(this.inviteEntities, function(invite) {
        return invite.status === 'redeemed';
      });

      var expired = _.select(this.inviteEntities, function(invite) {
        return invite.status == 'expired';
      });

      this.available = 123;
      this.pending = pending.length;
      this.accepted = accepted.length;
      this.expired = expired.length;
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
          this.root.$log.debug(data);
        }, () => {
          // cancel
          this.root.$log.debug('cancel');
        });
    }
  }

  controllerModule.controller(InviteGridController.ControllerId, InviteGridController);
}
