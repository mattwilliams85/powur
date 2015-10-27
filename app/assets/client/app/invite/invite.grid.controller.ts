/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../layout/auth.controller.ts' />
/// <reference path='invite.controller.ts' />

module powur {
  'use strict';

  class NewInviteGridDialogController extends NewInviteDialogController {
    static ControllerId = 'NewInviteGridDialogController';
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

  class InviteGridController extends AuthController {
    static ControllerId = 'InviteGridController';
    static $inject = ['invites', '$mdDialog', '$interval', '$timeout'];

    get unlimitedInvites(): boolean {
      return !this.invites.properties.limited_invites
    }

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
      if (_.isEmpty(this.filters)) {
        return this.invites.entities;
      } else {
        return _.filter(this.invites.entities, (i) => {
          return _.includes(this.filters, i['properties']['status']);
        });
      }
    }

    filters: string[] = [];

    constructor(private invites: ISirenModel,
                public $mdDialog: ng.material.IDialogService,
                private $interval: ng.IIntervalService,
                private $timeout: ng.ITimeoutService) {
      super();

      $interval(() => {
        this.updateTimers();
      }, 1000)


      $timeout(() => {
        this.updateTimers();
        this.buildPies();
      });
    }

    progress(item): number {
      return item.properties.time_left / 86400000;
    }

    // TODO: move this to an angular custom filter (might already exist as angular-moment?)
    dateFormat(item, format): string {
      return moment.utc(item.properties.time_left).format(format);
    }

    buildPies(): void {

      var options = {
        segmentShowStroke: false,
        animation: true
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
        this.updatePie(myPieChart, i);
      }
    }

    updatePie(chart, i): void {
      this.$interval(() => {
        var progress = this.progress(this.list[i]);
        chart.segments[0].value = progress;
        chart.segments[1].value = 1 - progress;
        chart.update();
      }, 1000)
    }

    updateTimers(): void {
      for (var i = 0; i < this.list.length; i++) {
        if (this.list[i].properties.time_left <= 0) {
          this.list[i].properties.time_left = 0;
          continue;
        }
        this.list[i].properties.time_left -= 1000;
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
          invites: this.invites
        }
      }).then((data: any) => {
        // ok
        this.invites.entities.unshift(data);
        this.invites.properties.pending_count += 1;
        this.invites.properties.available_count -= 1;
        this.buildPies();
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
    .controller(NewInviteGridDialogController.ControllerId, NewInviteGridDialogController)
    .controller(InviteGridController.ControllerId, InviteGridController);
}
