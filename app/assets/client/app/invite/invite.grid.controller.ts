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

    get available(): number {
      return this.invites.properties.available_count;
    }

    get pending(): number {
      return this.invites.properties.pending_count;
    }

    get accepted(): number {
      return this.invites.properties.accepted_count;
    }

    get expired(): number {
      return this.invites.properties.expired_count;
    }

    get list(): any[] {
      return this.invites.entities;
    }

    timerColor: string;

    constructor(private invites: ISirenModel,
                public $mdDialog: ng.material.IDialogService) {
      super();

      this.timerColor = '#2583a8';

      console.log('list', this.list);
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
