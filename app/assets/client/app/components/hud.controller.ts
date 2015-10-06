/// <reference path='../_references.ts' />

module powur {
    export interface IHudController {
        
    }
    
    class HudController implements IHudController {
        public static ControllerId: string = 'HudController';
        public static $inject: Array<string> = ['$log', '$interval', 'CacheService'];
        
        public fullName: string;
        
        public rank: number;
        public rankTotal: number;
        public gridSize: number;
        public dollarsEarned: number;
        public co2: number;
        public loginStreaks: number;
        
        public personalProposals: number;
        public teamProposals: number;
        
        constructor(private $log: ng.ILogService, private $interval: ng.IIntervalService, private cache: ICacheService) {
            var self = this;
            self.$log.debug(HudController.ControllerId + ':ctor');
            
            // sample data
            self.fullName = self.cache.user.displayName;
            
            self.rank = 2;
            self.rankTotal = 8; 
            
            self.gridSize = 18;
            
            self.dollarsEarned = 1880.89;
            
            self.co2 = 72.36;
            self.loginStreaks = 26;

            self.personalProposals = 10;
            self.teamProposals = 0;
            
            self.$interval(() => {
                self.personalProposals = self.personalProposals > 100 ? 20 : self.personalProposals + 1;
                self.teamProposals = self.personalProposals > 100 ? 0 : self.personalProposals + 2;
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