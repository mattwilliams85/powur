/// <reference path='invite.controller.ts' />

module powur {
  'use strict';

  class NewInviteSolarDialogController extends NewInviteDialogController {
    static ControllerId = 'NewInviteSolarDialogController';
    static $inject = ['$log', '$mdDialog', 'invites'];

    constructor($log: ng.ILogService,
                $mdDialog: ng.material.IDialogService,
                private invites: ISirenModel) {
      super($log, $mdDialog);
      this.create.field('first_name').value = null;
      this.create.field('last_name').value = null;
      this.create.field('email').value = null;
      this.create.field('phone').value = null;
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

  class UpdateInviteSolarDialogController extends NewInviteDialogController {
    static ControllerId = 'UpdateInviteSolarDialogController';
    static $inject = ['$log', '$mdDialog', 'parentCtrl', 'invite'];

    constructor($log: ng.ILogService,
                $mdDialog: ng.material.IDialogService,
                private parentCtrl: ng.IScope,
                public invite: any) {
      super($log, $mdDialog);

      this.update.field('first_name').value = this.invite.properties.first_name;
      this.update.field('last_name').value = this.invite.properties.last_name;
      this.update.field('email').value = this.invite.properties.email;
      this.update.field('phone').value = this.invite.properties.phone;

    }

    remove() {
      this.delete.submit().then((response: ng.IHttpPromiseCallbackArg<any>) => {
        this.$mdDialog.hide(response.data);
      });
    }

    resendInvite() {
      this.resend.submit().then((response: ng.IHttpPromiseCallbackArg<any>) => {
        this.$mdDialog.hide(response.data);
      });
    }

    updateInvite() {
      this.update.submit().then((response: ng.IHttpPromiseCallbackArg<any>) => {
        this.$mdDialog.hide(response.data);
      });
    }

    showLink(event, invite) {
      event.target.innerHTML = 'powur.com/next/join/grid/' + invite.id
    }

    get delete(): Action {
      return this.invite.action('delete');
    }

    get resend(): Action {
      return this.invite.action('resend');
    }

    get update(): Action {
      return this.invite.action('update');
    }
  }

  class InviteProductController extends AuthController {
    static ControllerId = 'InviteProductController';
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

    filters: any = {};

    constructor(private invites: ISirenModel, public $mdDialog: ng.material.IDialogService, public $timeout: ng.ITimeoutService) {
      super();
    }

    addInvite(e: MouseEvent) {
      this.$mdDialog.show({
        controller: 'NewInviteSolarDialogController as dialog',
        templateUrl: 'app/invite/new-invite-popup.solar.html',
        parent: angular.element('.invite.main'),
        targetEvent: e,
        clickOutsideToClose: true,
        locals: {
          invites: this.invites,
        }
      })
        .then((data: any) => {
          // ok
          console.log(this.invites)
          this.invites.entities.unshift(data);
          this.invites.properties.sent += 1;
        }, () => {
          // cancel
          this.root.$log.debug('cancel');
        });
    }

    showInvite(e: MouseEvent, invite) {
      this.$mdDialog.show({
        controller: 'UpdateInviteSolarDialogController as dialog',
        templateUrl: 'app/invite/show-invite-popup.solar.html',
        parent: angular.element('.invite.main'),
        targetEvent: e,
        clickOutsideToClose: true,
        preserveScope: true,
        locals: {
          parentCtrl: this,
          invite: invite
        }
      }).then((data: any) => {
        if (data) this.invites.entities = new SirenModel(data).entities;
      }, () => {
        // cancel
        this.root.$log.debug('cancel');
      });
    }

    inviteUpdate(e: MouseEvent, invite) {
      this.$mdDialog.show({
        controller: 'UpdateInviteSolarDialogController as dialog',
        templateUrl: 'app/invite/update-invite-popup.solar.html',
        parent: angular.element('.invite.main'),
        targetEvent: e,
        clickOutsideToClose: true,
        locals: {
          parentCtrl: this,
          invite: invite
        }
      }).then((data: any) => {
        if (data) this.invites.entities = new SirenModel(data).entities;
      }, () => {
        // cancel
      });
    }

    filter(name: string) {
      var opts = { page: 1 };
      this.filters.status = this.filters.status == name ? '' : name;

      for (var key in this.filters) {
        opts[key] = this.filters[key];
      }

      this.session.getEntity(SirenModel, this.invites.rel[0], opts, true)
        .then((data: any) => {
          this.invites.entities = data.entities;
          this.invites.properties = data.properties;
      });
    }
  }

  angular
    .module('powur.invite')
    .controller(NewInviteSolarDialogController.ControllerId, NewInviteSolarDialogController)
    .controller(UpdateInviteSolarDialogController.ControllerId, UpdateInviteSolarDialogController)
    .controller(InviteProductController.ControllerId, InviteProductController);
}
