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

    get goalPersonalRequirement(): ISirenModel {
      return _.find(this.goalRequirements, function(i) {
        return i.properties.team == false;
      });
    }

    get goalTeamRequirement(): ISirenModel {
      return _.find(this.goalRequirements, function(i) {
        return i.properties.team == true;
      });
    }

    get isQualifiedPartnerCase(): boolean {
      return this.goalRequirements.length == 1 &&
               this.goalRequirements[0].properties.product_id == 1 &&
               this.goalRequirements[0].properties.quantity <= 3;
    }

    constructor(private $scope: IHudScope,
                private $log: ng.ILogService) {
    }

    nSizeArray(n): Array<number> {
      return new Array(n);
    }
  }

  angular
    .module('powur.layout')
    .controller(HudController.ControllerId, HudController);
}
