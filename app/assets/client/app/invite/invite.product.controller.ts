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
      if (_.isEmpty(this.filters)) {
        return this.invites.entities;
      } else {
        return _.filter(this.invites.entities, (i) => {
          return _.includes(this.filters, i['properties']['status']);
        });
      }
    }

    get listProps(): any {
      return this.invites.properties;
    }

    filters: string[] = [];

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

    filter(type: string) {
      var index = this.filters.indexOf(type);
      if (index > -1) {
        this.filters.splice(index, 1);
      } else {
        this.filters.push(type);
      }
    }
  }

  angular
    .module('powur.invite')
    .controller(NewInviteSolarDialogController.ControllerId, NewInviteSolarDialogController)
    .controller(InviteProductController.ControllerId, InviteProductController);
}
