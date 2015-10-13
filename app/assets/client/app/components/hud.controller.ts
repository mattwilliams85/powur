/// <reference path='../_references.ts' />

module powur {
  interface IHudScope extends ng.IScope {
    home: any;
  }
  
  class HudController {
    static ControllerId = 'HudController';
    static $inject = ['$scope', '$log', '$interval'];
    
    fullName: string;
    
    rank: number;
    rankTotal: number;
    gridSize: number;
    dollarsEarned: number;
    co2: number;
    loginStreaks: number;
    
    personalProposals: number;
    teamProposals: number;

    get userData(): any {
      return this.$scope.home.userData;
    }
    
    constructor(private $scope: IHudScope,
                private $log: ng.ILogService,
                private $interval: ng.IIntervalService) {
      
      // sample data
      
      this.rank = 2;
      this.rankTotal = 8; 
      
      this.gridSize = 18;
      
      this.dollarsEarned = 1880.89;
      
      this.co2 = 72.36;
      this.loginStreaks = 26;

      this.personalProposals = 10;
      this.teamProposals = 0;
      
      this.$interval(() => {
        this.personalProposals = this.personalProposals > 100 ? 20 : this.personalProposals + 1;
        this.teamProposals = this.personalProposals > 100 ? 0 : this.personalProposals + 2;
      }, 100, 0, true);
    }

  }
  
  controllerModule.controller(HudController.ControllerId, HudController);
}