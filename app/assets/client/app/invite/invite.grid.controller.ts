/// <reference path='../_references.ts' />

module powur {
  class NewInviteGridDialogController extends NewInviteDialogController {
    static ControllerId = 'NewInviteGridDialogController';
    static $inject = ['$log', '$mdDialog', 'invites'];

    constructor($log: ng.ILogService,
                $mdDialog: ng.material.IDialogService,
                private invites: ISirenModel) {
      super($log, $mdDialog);
    }

    send() {
      this.create.submit().then((response: ng.IHttpPromiseCallbackArg<any>) => {
        this.$mdDialog.hide(response.data);
        this.create.clearValues();
      });
    }

    get create(): Action {
      return this.invites.action('create');
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

    constructor(private invites: ISirenModel,
                public $mdDialog: ng.material.IDialogService) {
      super();

      this.timerColor = '#2583a8';

      var pending = _.select(this.invites.entities, function(invite) {
        return invite['properties'].status === 'valid';
      });

      var accepted = _.select(this.invites.entities, function(invite) {
        return invite['properties'].status === 'redeemed';
      });

      var expired = _.select(this.invites.entities, function(invite) {
        return invite['properties'].status == 'expired';
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
        clickOutsideToClose: true,
        locals: {
          invites: this.invites
        }
      }).then((data: any) => {
        // ok
        this.invites.entities.unshift(data);
        this.pending += 1;
        this.available -= 1;
      }, () => {
        // cancel
        this.root.$log.debug('cancel');
      });
    }
  }

  controllerModule.controller(InviteGridController.ControllerId, InviteGridController);
}
