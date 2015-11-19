/// <reference path='invite.controller.ts' />

module powur {
  'use strict';

  class InviteSolarController extends InviteController {
    static ControllerId = 'InviteSolarController';
    static $inject = ['invites', '$mdDialog', '$timeout'];

    get list(): any[] {
      return this.invites.entities;
    }

    get listProps(): any {
      return this.invites.properties;
    }

    get showFilters(): boolean {
      return !!(this.listProps.sent ||
                this.listProps.ineligible_location ||
                this.listProps.initiated);
    }

    constructor(public invites: ISirenModel, 
                public $mdDialog: ng.material.IDialogService, 
                public $timeout: ng.ITimeoutService) {
      super();
    }

    addInvite(e: MouseEvent) {
      this.$mdDialog.show({
        controller: 'NewInviteDialogController as dialog',
        templateUrl: 'app/invite/new-invite-popup.solar.html',
        parent: angular.element('body'),
        targetEvent: e,
        clickOutsideToClose: true,
        locals: {
          invites: this.invites,
        }
      })
        .then((data: any) => {
          this.invites.entities.unshift(new SirenModel(data));
          this.invites.properties.sent += 1;
        });
    }

    showInvite(e: MouseEvent, invite) {
      this.$mdDialog.show({
        controller: 'UpdateInviteDialogController as dialog',
        templateUrl: 'app/invite/show-invite-popup.solar.html',
        parent: angular.element('body'),
        targetEvent: e,
        clickOutsideToClose: true,
        locals: {
          parentCtrl: this,
          invite: invite
        }
      }).then((data: any) => {
        if (data) this.invites.entities = new SirenModel(data).entities;
      });
    }

    inviteUpdate(e: MouseEvent, invite) {
      this.$mdDialog.show({
        controller: 'UpdateInviteDialogController as dialog',
        templateUrl: 'app/invite/update-invite-popup.solar.html',
        parent: angular.element('body'),
        targetEvent: e,
        clickOutsideToClose: true,
        locals: {
          parentCtrl: this,
          invite: invite
        }
      }).then((data: any) => {
        if (data) this.invites.entities = new SirenModel(data).entities;
      });
    }

    filterSuccess(data, scope) {
      scope.invites.entities = data.entities;
      scope.invites.properties = data.properties;
    }
  }

  angular
    .module('powur.invite')
    .controller(NewInviteDialogController.ControllerId, NewInviteDialogController)
    .controller(UpdateInviteDialogController.ControllerId, UpdateInviteDialogController)
    .controller(InviteController.ControllerId, InviteController)
    .controller(InviteSolarController.ControllerId, InviteSolarController);
}
