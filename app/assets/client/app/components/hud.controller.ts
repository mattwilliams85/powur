/// <reference path='../_references.ts' />

module powur {
  class HudController {
    static ControllerId: string = 'HudController';
    static $inject: Array<string> = ['$log', '$interval', 'CacheService'];
    
    fullName: string;
    
    rank: number;
    rankTotal: number;
    gridSize: number;
    dollarsEarned: number;
    co2: number;
    loginStreaks: number;
    
    personalProposals: number;
    teamProposals: number;
    
    constructor(private $log: ng.ILogService, private $interval: ng.IIntervalService, private cache: ICacheService) {
      this.$log.debug(HudController.ControllerId + ':ctor');
      
      // sample data
      this.fullName = this.cache.user.displayName;
      
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
    
    //TODO: move to service
    // public static getRootController(): IRootController {
    //     var root = angular.element('body').scope();
    //     return (<any>root).root;
    // }           
  }
  
  controllerModule.controller(HudController.ControllerId, HudController);
}