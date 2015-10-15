/// <reference path='../_references.ts' />

module powur {
  class NewInviteSolarDialogController extends NewInviteDialogController {
    static ControllerId = 'NewInviteSolarDialogController';
    static $inject = ['$log', '$mdDialog', 'invites'];

    constructor($log: ng.ILogService,
                $mdDialog: ng.material.IDialogService,
                private invites: ISirenModel) {
      super($log, $mdDialog);
    }

    send() {
      this.create.submit().then((response: ng.IHttpPromiseCallbackArg<any>) => {
        this.$mdDialog.hide(response.data);
      });
    }

    get create(): Action {
      return this.invites.action('create');
    }
  }

  controllerModule.controller(NewInviteSolarDialogController.ControllerId, NewInviteSolarDialogController);

  class InviteProductController extends AuthController {
    static ControllerId = 'InviteProductController';
    static $inject = ['invites', '$mdDialog'];

    get list(): any[] {
      return this.invites.entities;
    }

    get listProps(): any {
      return this.invites.properties;
    }

    timerColor: string;

    constructor(private invites: ISirenModel, public $mdDialog: ng.material.IDialogService) {
      super();
      this.timerColor = '#39ABA1';
    }

    addInvite(e: MouseEvent) {
      this.$mdDialog.show({
        controller: 'NewInviteSolarDialogController as dialog',
        templateUrl: 'app/invite/new-invite-popup.solar.html',
        parent: angular.element(document.body),
        targetEvent: e,
        clickOutsideToClose: true,
        locals: {
          invites: this.invites
        }
      })
        .then((data: any) => {
          // ok
          this.invites.entities.unshift(data);
          this.invites.properties.sent += 1;
        }, () => {
          // cancel
          this.root.$log.debug('cancel');
        });
    }
  }

  controllerModule.controller(InviteProductController.ControllerId, InviteProductController);
}
