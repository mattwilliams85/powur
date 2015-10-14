/// <reference path='../_references.ts' />

module powur {
  
  class News {
    date: Date;
    imageUrl: string;
    caption: string;    
  }
  
  class Sort {
    id: number;
    name: string;
  }
  
  class ActivityController {
    static ControllerId: string = 'ActivityController';
    static $inject: Array<string> = ['$log'];
    
    sortId: number;
    sorting: Array<Sort>;
    
    news: Array<News>;
    
    constructor(private $log: ng.ILogService) {
      this.$log.debug(ActivityController.ControllerId + ':ctor');
      
      // sample data
      this.sorting = [{ id: 0, name: 'Date'}];
      
      this.news = [
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
