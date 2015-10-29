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

  class InviteProductController extends AuthController {
    static ControllerId = 'InviteProductController';
    static $inject = ['invites', '$mdDialog', '$timeout'];

    get list(): any[] {
      return this.invites.entities;
    }

    get listProps(): any {
      return this.invites.properties;
    }

    filters: any = {};

    constructor(private invites: ISirenModel, public $mdDialog: ng.material.IDialogService, public $timeout: ng.ITimeoutService) {
      super();
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
    .controller(InviteProductController.ControllerId, InviteProductController);
}
