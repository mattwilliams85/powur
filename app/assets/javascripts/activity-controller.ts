/// <reference path='../typings/tsd.d.ts' />
/// <reference path='boot.ts' />
module powur.controllers {
    
    class News {
        date: Date;
        imageUrl: string;
        caption: string;    
    }
    
    class Sort {
        id: number;
        name: string;
    }
    
    export interface IActivityController {
        
    }
    
    class ActivityController implements IActivityController {
        public static ControllerId: string = 'ActivityController';
        public static $inject: Array<string> = ['$log'];
        
        public sortId: number;
        public sorting: Array<Sort>;
        
        public news: Array<News>;
        
        constructor(private $log: ng.ILogService) {
            var self = this;
            self.$log.debug(ActivityController.ControllerId + ':ctor');
            
            // sample data
            self.sorting = [{ id: 0, name: 'Date'}];
            
            self.news = [
                { date: new Date(), imageUrl: 'news', caption: 'Renewables Win Again! Landmark Settlement Propmts 200th Coal Plant to Retire production.' },
                { date: new Date(), imageUrl: 'news', caption: 'Renewables Win Again! Landmark Settlement Propmts 200th Coal Plant to Retire production.' },
                { date: new Date(), imageUrl: 'news', caption: 'Renewables Win Again! Landmark Settlement Propmts 200th Coal Plant to Retire production.' },
                { date: new Date(), imageUrl: 'news', caption: 'Renewables Win Again! Landmark Settlement Propmts 200th Coal Plant to Retire production.' },
                { date: new Date(), imageUrl: 'news', caption: 'Renewables Win Again! Landmark Settlement Propmts 200th Coal Plant to Retire production.' },
                { date: new Date(), imageUrl: 'news', caption: 'Renewables Win Again! Landmark Settlement Propmts 200th Coal Plant to Retire production.' },
            ];
        }
    }
    
    controllerModule.controller(ActivityController.ControllerId, ActivityController);
}