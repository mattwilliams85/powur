/// <reference path='../../typings/tsd.d.ts' />

module powur {
  interface IHudScope extends ng.IScope {
    home: any;
  }

  class HudController {
    static ControllerId = 'HudController';
    static $inject = ['$scope', '$log'];


    get home(): any {
      return this.$scope.home;
    }

    get userData(): any {
      return this.home.userData;
    }

    get rank(): number {
      return this.home.goals.properties.next_rank - 1;
    }

    get rankTitle(): number {
      return this.home.goals.properties.lifetime_rank_title;
    }

    get rankTotal(): number {
      return this.home.goals.properties.rank_list.length - 1;
    }

    get goalRequirements(): ISirenModel[] {
      return this.home.requirements.entities;
    }

    constructor(private $scope: IHudScope,
                private $log: ng.ILogService) {
    }

  }

  angular
    .module('powur.layout')
    .controller(HudController.ControllerId, HudController);
}
