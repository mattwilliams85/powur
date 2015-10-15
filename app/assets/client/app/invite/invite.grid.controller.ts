/// <reference path='../_references.ts' />

module powur {
  class NewInviteGridDialogController extends NewInviteDialogController {
    static ControllerId = 'NewInviteGridDialogController';
    static $inject = ['$log', '$mdDialog'];

    constructor($log: ng.ILogService, $mdDialog: ng.material.IDialogService) {
      super($log, $mdDialog);
    }
  }

  controllerModule.controller(NewInviteGridDialogController.ControllerId, NewInviteGridDialogController);

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

      this.available = this.invites.properties.available_count;
      this.pending = pending.length;
      this.accepted = accepted.length;
      this.expired = this.invites.properties.expired_count;
    }

    addInvite(e: MouseEvent) {
      this.$mdDialog.show({
        controller: 'NewInviteGridDialogController as dialog',
        templateUrl: 'app/invite/new-invite-popup.grid.html',
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
