/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../layout/auth.controller.ts' />

module powur {
  'use strict';

  interface Warning {
    type: string;
    message: string;
    input: string;
  }

  export class NewInviteDialogController {
    static ControllerId = 'NewInviteDialogController';
    static $inject = ['$log', '$mdDialog', 'invites'];

    invites: ISirenModel;
    warning: Warning;

    constructor(private $log: ng.ILogService, public $mdDialog: ng.material.IDialogService, invites: ISirenModel) {
      this.invites = invites;

      for (var i = 0; i < this.create.fields.length; i++) {
        this.fields[i].value = null;
        this.fields[i].$error = null;
      }
    }

    send() {
      this.create.submit().then((response: ng.IHttpPromiseCallbackArg<any>) => {
        if (response.data.warning) {
          this.warning = response.data.warning;
        } else {
          this.$mdDialog.hide(response.data);
          this.create.clearValues();
        }
      });
    }

    confirm() {
      this.create.field('confirm_existing_email').value = '1';
      this.send();
    }

    cancel() {
      this.$mdDialog.cancel();
    }

    get create(): Action { return this.invites.action('create') }
    get fields(): any    { return this.create.fields }
  }

  export class UpdateInviteDialogController {
    static ControllerId = 'UpdateInviteDialogController';
    static $inject = ['$log', '$mdDialog', 'parentCtrl', 'invite'];

    parentCtrl: any;
    invite: any;

    constructor(private $log: ng.ILogService,
                public $mdDialog: ng.material.IDialogService,
                parentCtrl: ng.IScope,
                invite: any) {

      this.invite = invite;
      this.parentCtrl = parentCtrl;

      for (var i = 0; i < this.fields.length; i++) {
        this.fields[i].value = this.invite.properties[ this.fields[i].name ];
      }

      this.invite.entity('invite-email').get((email_data: any) => {
        this.invite.properties.email_data = email_data.properties;
      });
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

    showLink(invite): string {
      return 'https://powur.com/next/join/grid/' + invite.id;
    }

    cancel() {
      this.$mdDialog.cancel();
    }

    get delete(): Action { return this.invite.action('delete') }
    get resend(): Action { return this.invite.action('resend') }
    get update(): Action { return this.invite.action('update') }
    get fields(): any    { return this.update.fields }
  }

  export class InviteController extends AuthController {
    static ControllerId = 'InviteController';

    invites: ISirenModel;

    isCurrent(state: string): boolean {
      return this.state.current.name == state;
    }

    filter(name: string, success) {
      var opts = {
        page: 1,
        status: name || ''
      };
      this.session.getEntity(SirenModel, this.invites.rel[0], opts, true)
        .then((data: any) => {
          success(data, this);
        });
    }
  }

  angular
    .module('powur.invite')
    .controller(InviteController.ControllerId, InviteController);
}
