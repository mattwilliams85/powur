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

    activePies: string[];

    constructor(public invites: ISirenModel,
                public $mdDialog: ng.material.IDialogService,
                private $interval: ng.IIntervalService,
                private $timeout: ng.ITimeoutService,
                private $window: ng.IWindowService,
                private $scope: ng.IScope) {
      super();  
      
      this.$interval.cancel(this.invites.properties.pieTimer);
      this.activePies = [];

      this.$timeout(() => {
        this.invites.properties.pieTimer = this.$interval(() => {
            this.startTimers();
        }, 1000)
        this.buildPies();
      });

      //Redraws canvases on resize
      $scope.$watch(function(){
           return $window.innerWidth;
        }, () => {
           this.buildPies();
       });
    }

    progress(item): number {
      var prog = item.properties.time_left / 86400000;
      return Math.ceil(prog * 50) / 50;
    }

    dateFormat(item, format): string {
      if (!item.properties.time_left) return 'expired';
      return moment.utc(item.properties.time_left).format(format);
    }

    buildPies(): void {
      this.$timeout(() => {
        var options = {
          segmentShowStroke: false,
          showTooltips: false,
          responsive: true
        }
        for (var i = 0; i < this.list.length; i++) {
          var id = this.list[i].properties.id;

          if (this.activePies.indexOf(id) > -1 || 
              this.list[i].properties.status === 'expired') continue;

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
          this.activePies.push(id)
        }
      })
    }

    startTimers(): void {
      for (var i = 0; i < this.list.length; i++) {
        this.list[i].properties.time_left -= 1000;
        if (this.list[i].properties.time_left <= 0) {
          this.list[i].properties.time_left = 0;
        }
      }
    }

    addInvite(e: MouseEvent) {
      this.$mdDialog.show({
        controller: 'NewInviteDialogController as dialog',
        templateUrl: 'app/invite/new-invite-popup.grid.html',
        parent: angular.element('body'),
        targetEvent: e,
        clickOutsideToClose: true,
        locals: {
          invites: this.invites
        }
      }).then((data: any) => {
        this.invites.entities.push(new SirenModel(data));
        this.invites.properties.pending_count += 1;

        this.buildPies();
      });
    }

    showInvite(e: MouseEvent, invite) {
      this.$mdDialog.show({
        controller: 'UpdateInviteDialogController as dialog',
        templateUrl: 'app/invite/show-invite-popup.grid.html',
        parent: angular.element('body'),
        targetEvent: e,
        clickOutsideToClose: true,
        locals: {
          parentCtrl: this,
          invite: invite
        }
      }).then((data: any) => {
        if (data) {
          this.invites.entities = new SirenModel(data).entities;
          this.buildPies();
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
        locals: {
          parentCtrl: this,
          invite: invite
        }
      }).then((data: any) => {
         this.invites.entities = new SirenModel(data).entities;
         this.buildPies();
      });
    }

    filterSuccess(data, scope) {
      data.properties.pieTimer = scope.invites.properties.pieTimer;
      scope.invites.entities = data.entities;
      scope.invites.properties = data.properties;
      scope.activePies = [];
      scope.buildPies();
    }
  }

  angular
    .module('powur.invite')
    .controller(NewInviteDialogController.ControllerId, NewInviteDialogController)
    .controller(UpdateInviteDialogController.ControllerId, UpdateInviteDialogController)
    .controller(InviteController.ControllerId, InviteController)
    .controller(InviteGridController.ControllerId, InviteGridController);
}
