/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../layout/auth.controller.ts' />
/// <reference path='invite.controller.ts' />

module powur {
  'use strict';

  class NewInviteGridDialogController extends NewInviteDialogController {
    static ControllerId = 'NewInviteGridDialogController';
    static $inject = ['$log', '$mdDialog', 'invites', 'invite'];

    constructor($log: ng.ILogService,
                $mdDialog: ng.material.IDialogService,
                private invites: ISirenModel,
                public invite: ISirenModel) {
      super($log, $mdDialog);

      if (this.create) {
        this.create.field('first_name').value = null;
        this.create.field('last_name').value = null;
        this.create.field('email').value = null;
        this.create.field('phone').value = null;
        this.create.field('first_name').$error = null;
        this.create.field('last_name').$error = null;
        this.create.field('email').$error = null;
        this.create.field('phone').$error = null;
      }
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

  class UpdateInviteGridDialogController extends NewInviteDialogController {
    static ControllerId = 'UpdateInviteGridDialogController';
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
      return 'powur.com/next/join/grid/' + invite.id;
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

  class InviteGridController extends AuthController {
    static ControllerId = 'InviteGridController';
    static $inject = ['invites', '$mdDialog', '$interval', '$timeout'];

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

    get showFilters(): boolean {
      return !!(this.pending || this.expired);
    }

    filters: any = {};

    constructor(private invites: ISirenModel,
                public $mdDialog: ng.material.IDialogService,
                private $interval: ng.IIntervalService,
                private $timeout: ng.ITimeoutService) {
      super();

      this.$interval.cancel(this.invites.properties.pieTimer);

      this.$timeout(() => {
        this.invites.properties.pieTimer = this.$interval(() => {
            this.updateTimers();
        }, 1000)
        this.buildPies();
      });
    }

    progress(item): number {
      var prog = item.properties.time_left / 86400000;
      return Math.ceil(prog * 50) / 50;
    }

    // TODO: move this to an angular custom filter (might already exist as angular-moment?)
    dateFormat(item, format): string {
      if (!item.properties.time_left) return 'expired';
      return moment.utc(item.properties.time_left).format(format);
    }

    buildPies(): void {
      var options = {
        segmentShowStroke: false,
        showTooltips: false,
        responsive: true
      }
      for (var i = 0; i < this.list.length; i++) {
        if (this.list[i].properties.status === 'expired') continue;
        var id = this.list[i].properties.id;
        var progress = this.progress(this.list[i]);
        var data = [
          {
            value: progress,
            color: "#2583a8",
            highlight: "#2583a8",
            label: "Complete"
          },
          {
            value: 1 - progress,
            color: "#c5c5c5",
            label: "Incomplete"
          }
        ]
        var canvas = <HTMLCanvasElement>document.getElementById('pie-' + id);
        var ctx = canvas.getContext('2d');
        var myPieChart = new Chart(ctx).Pie(data, options);
        // this.updatePie(myPieChart, i);
      }
    }

    // updatePie(chart, i): void {
    //   this.$interval(() => {
    //     var progress = this.progress(this.list[i]);
    //     chart.segments[0].value = progress;
    //     chart.segments[1].value = 1 - progress;
    //     chart.update();
    //   }, 1000)
    // }

    updateTimers(): void {
      for (var i = 0; i < this.list.length; i++) {
        this.list[i].properties.time_left -= 1000;
        if (this.list[i].properties.time_left <= 0) {
          this.list[i].properties.time_left = 0;
        }
      }
    }

    addInvite(e: MouseEvent) {
      this.$mdDialog.show({
        controller: 'NewInviteGridDialogController as dialog',
        templateUrl: 'app/invite/new-invite-popup.grid.html',
        parent: angular.element('.invite.main'),
        targetEvent: e,
        clickOutsideToClose: true,
        locals: {
          invite: {},
          invites: this.invites
        }
      }).then((data: any) => {
        // ok
        this.invites.entities.unshift(new SirenModel(data));
        this.invites.properties.pending_count += 1;
        setTimeout(() => {
          this.buildPies();
        });
      }, () => {
        // cancel
        this.root.$log.debug('cancel');
      });
    }

    showInvite(e: MouseEvent, invite) {
      this.$mdDialog.show({
        controller: 'UpdateInviteGridDialogController as dialog',
        templateUrl: 'app/invite/show-invite-popup.grid.html',
        parent: angular.element('.invite.main'),
        targetEvent: e,
        clickOutsideToClose: true,
        preserveScope: true,
        locals: {
          parentCtrl: this,
          invite: invite
        }
      }).then((data: any) => {
        if (data) {
          this.invites.entities = new SirenModel(data).entities;
          setTimeout(() => {
            this.buildPies();
          });
        }
      }, () => {
        // cancel
        this.root.$log.debug('cancel');
      });
    }

    inviteUpdate(e: MouseEvent, invite) {
      this.$mdDialog.show({
        controller: 'UpdateInviteGridDialogController as dialog',
        templateUrl: 'app/invite/update-invite-popup.grid.html',
        parent: angular.element('.invite.main'),
        targetEvent: e,
        clickOutsideToClose: true,
        locals: {
          parentCtrl: this,
          invite: invite
        }
      }).then((data: any) => {
         this.invites.entities = new SirenModel(data).entities;
         setTimeout(() => {
           this.buildPies();
         });
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
          var pieTimer = this.invites.properties.pieTimer;
          this.invites.properties = data.properties;
          this.invites.properties.pieTimer = pieTimer;
          setTimeout(() => {
            this.buildPies();
          });
      });
    }
  }

  angular
    .module('powur.invite')
    .controller(NewInviteGridDialogController.ControllerId, NewInviteGridDialogController)
    .controller(UpdateInviteGridDialogController.ControllerId, UpdateInviteGridDialogController)
    .controller(InviteGridController.ControllerId, InviteGridController);
}
