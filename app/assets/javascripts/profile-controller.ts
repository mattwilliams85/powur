/// <reference path='../typings/tsd.d.ts' />
/// <reference path='../typings/references.d.ts' />

module powur.controllers {
    export interface IProfileController {
        
    }
    
    class ProfileController implements IProfileController {
        public static ControllerId: string = 'ProfileController';
        public static $inject: Array<string> = ['$log', '$interval'];
        
        public fullName: string;
        
        public rank: number;
        public rankTotal: number;
        public gridSize: number;
        public dollarsEarned: number;
        public co2: number;
        public loginStreaks: number;
        
        public personalProposals: number;
        public teamProposals: number;
        
        constructor(private $log: ng.ILogService, private $interval: ng.IIntervalService) {
            var self = this;
            self.$log.debug(ProfileController.ControllerId + ':ctor');
            
            // sample data
            self.fullName = "Lyndia Portman";
            
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
        
        //TODO: convert to filter
        public getWhole(v: number): string {
            return this.toCommas(Math.floor(v));
        }
        
        public getDecimal(v: number): string {
            return (v % 1).toFixed(2).substring(2,4);
        }
        
        private toCommas(v: number): string {
            return v.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        }
    }
    
    controllerModule.controller(ProfileController.ControllerId, ProfileController);
}