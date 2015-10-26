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
    static $inject = ['invites', '$mdDialog', '$interval'];

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
    timerColor: string = '#2583a8';

    constructor(private invites: ISirenModel,
                public $mdDialog: ng.material.IDialogService,
                private $interval: ng.IIntervalService) {
      super();

      $interval(() => {
        this.startTimers();
      }, 1000)
    }

    // TODO: Serious refactor needed
    startTimers(): void {
      for (var i = 0; i < this.list.length; i++) {
        var item = this.list[i].properties;

        var x = new Date();
        var jan = new Date(x.getFullYear(), 0, 1);
        var jul = new Date(x.getFullYear(), 6, 1);
        var stdTimezoneOffset = Math.max(jan.getTimezoneOffset(), jul.getTimezoneOffset());
        var currentTimeZoneOffsetInHours = x.getTimezoneOffset() / 60;
        var time = new Date(this.list[i].properties.expires).getTime() - new Date().getTime();
        if(stdTimezoneOffset > x.getTimezoneOffset()) currentTimeZoneOffsetInHours=currentTimeZoneOffsetInHours+1;
        time=time+(currentTimeZoneOffsetInHours*3600000);

        if (time <= 0) {
          time = 0;
          continue;
        }
        this.list[i].properties.time_left = time;
        this.list[i].properties.expiration_progress = item.expiration_progress + 0.0000115;
      }
    }

    // calculateExp(item: any): any {
    //   var start = new Date(item.created_at).getTime();
    //   var end = item.expires;
    //   var now = new Date().getTime();
    //   // debugger
    //   return 1 - ((now - start) / (end - start));
    // }

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
