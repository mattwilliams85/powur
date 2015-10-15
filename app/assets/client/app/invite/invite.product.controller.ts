/// <reference path='../_references.ts' />

module powur {
  class NewInviteSolarDialogController extends NewInviteDialogController {
    static ControllerId = 'NewInviteSolarDialogController';
    static $inject = ['$log', '$mdDialog'];

    constructor($log: ng.ILogService, $mdDialog: ng.material.IDialogService) {
      super($log, $mdDialog);
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
      var isCustomer = false;
      this.timerColor = isCustomer ? '#2583a8' : '#39ABA1';
    }
    
    
    addInvite(item: InviteItem, e: MouseEvent) {
      this.$mdDialog.show({
        controller: 'NewInviteSolarDialogController as dialog',
        templateUrl: 'app/invite/new-invite-popup.solar.html',
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

  controllerModule.controller(InviteProductController.ControllerId, InviteProductController);
}
