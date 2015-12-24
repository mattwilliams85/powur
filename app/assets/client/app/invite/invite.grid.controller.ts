/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../layout/auth.controller.ts' />
/// <reference path='invite.controller.ts' />

module powur {
  'use strict';

  class InviteGridController extends InviteController {
    static ControllerId = 'InviteGridController';
    static $inject = ['invites', '$mdDialog', '$interval', '$timeout', '$window', '$scope'];

    get pending():  number     { return this.invites.properties.pending_count }
    get accepted(): number     { return this.invites.properties.accepted_count }
    get expired():  number     { return this.invites.properties.expired_count }
    get list(): any[]          { return this.invites.entities }
    get listProps(): any       { return this.invites.properties }
    get showFilters(): boolean { return !!(this.pending || this.expired) }

    constructor(public invites: ISirenModel,
                public $mdDialog: ng.material.IDialogService,
                private $interval: ng.IIntervalService,
                private $timeout: ng.ITimeoutService,
                private $window: ng.IWindowService,
                private $scope: ng.IScope) {
      super();
    }

    dateFormat(item, format): string {
      if (!item.properties.time_left) return 'expired';
      return moment.utc(item.properties.time_left).format(format);
    }

    addInvite(e: MouseEvent) {
      this.$mdDialog.show({
        controller: 'NewInviteDialogController as dialog',
        templateUrl: 'app/invite/new-invite-popup.grid.html',
        parent: angular.element('body'),
        targetEvent: e,
        fullscreen: true,
        clickOutsideToClose: true,
        locals: {
          invites: this.invites
        }
      }).then((data: any) => {
        this.invites.entities.push(new SirenModel(data));
        this.invites.properties.pending_count += 1;
      });
    }

    showInvite(e: MouseEvent, invite) {
      this.$mdDialog.show({
        controller: 'UpdateInviteDialogController as dialog',
        templateUrl: 'app/invite/show-invite-popup.grid.html',
        parent: angular.element('body'),
        targetEvent: e,
        clickOutsideToClose: true,
        fullscreen: true,
        locals: {
          parentCtrl: this,
          invite: invite
        }
      }).then((data: any) => {
        if (data) {
          data = new SirenModel(data);
          this.invites.entities = data.entities;
          this.invites.properties = data.properties;
        }
      });
    }

    inviteUpdate(e: MouseEvent, invite) {
      this.$mdDialog.show({
        controller: 'UpdateInviteDialogController as dialog',
        templateUrl: 'app/invite/update-invite-popup.grid.html',
        parent: angular.element('body'),
        targetEvent: e,
        clickOutsideToClose: true,
        fullscreen: true,
        locals: {
          parentCtrl: this,
          invite: invite
        }
      }).then((data: any) => {
         this.invites.entities = new SirenModel(data).entities;
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
    .controller(InviteGridController.ControllerId, InviteGridController);
}
