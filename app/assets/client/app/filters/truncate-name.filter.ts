/// <reference path='../_references.ts' />

module powur {
  class TruncateNameFilter {
    static FilterId: string = 'truncateName';
    static $inject: Array<string> = ['$log'];
    
    constructor(private $log: ng.ILogService) {
      var init = (input: string): string => {
        var deviceWidth = (window.innerWidth > 0) ? window.innerWidth : screen.width;
        var v = input;
        if(deviceWidth<720 || input.length>=8) v = input[0]+".";
        return v;        
      };
      
      return <any>init;
    } // ctor
  } // class
  
  directiveModule.filter(TruncateNameFilter.FilterId, <any>TruncateNameFilter);
}
