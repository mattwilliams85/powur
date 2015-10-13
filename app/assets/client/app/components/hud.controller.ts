/// <reference path='../_references.ts' />

module powur {
  interface IHudScope extends ng.IScope {
    home: any;
  }
  
  class HudController {
    static ControllerId = 'HudController';
    static $inject = ['$scope', '$log', '$interval'];
    
    gridSize: number;
    dollarsEarned: number;
    co2: number;
    loginStreaks: number;

    get home(): any {
      return this.$scope.home;
    }

    get userData(): any {
      return this.home.userData;
    }

    get rank(): number {
      return this.home.goals.properties.next_rank - 1;
    }

    get rankTotal(): number {
      return this.home.goals.properties.rank_list.length - 1;
    }

    get headshot(): string {
      var avatar = this.userData.avatar;
      var image = avatar ? avatar.large : '/assets/img/default-profile.png';
      return `url(${image})`;
    }

    get headshotStyle(): any {
      return { 'background-image': this.headshot };
    }

    get goalRequirements(): ISirenModel[] {
      return this.home.requirements.entities;
    }
    
    constructor(private $scope: IHudScope,
                private $log: ng.ILogService,
                private $interval: ng.IIntervalService) {
      
      this.gridSize = 18;
      
      this.dollarsEarned = 1880.89;
      
      this.co2 = 72.36;
      this.loginStreaks = 26;
    }

  }
  
  controllerModule.controller(HudController.ControllerId, HudController);
}