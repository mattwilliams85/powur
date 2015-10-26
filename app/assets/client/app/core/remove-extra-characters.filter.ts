/// <reference path='../../typings/tsd.d.ts' />

module powur {
  class RemoveExtraCharsFilter {
    static FilterId: string = 'removeExtraChars';
    static $inject: Array<string> = ['$log'];
    
    constructor(private $log: ng.ILogService) {
      var init = (input: string): string => {
        var v = input;
        v = v.replace("_", " ");
        return v;        
      };
      
      return <any>init;
    } // ctor
  } // class
  
  angular
    .module('powur.core')
    .filter(RemoveExtraCharsFilter.FilterId, <any>RemoveExtraCharsFilter);
}
