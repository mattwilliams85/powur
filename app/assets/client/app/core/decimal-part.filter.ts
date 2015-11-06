/// <reference path='../../typings/tsd.d.ts' />

module powur {
  class DecimalPartFilter {
    static FilterId: string = 'decimalPart';
    static $inject: Array<string> = ['$log'];
    
    constructor(private $log: ng.ILogService) {
      var init = (input: number): string => {
        return (input % 1).toFixed(2).substring(2, 4);
      };
      
      return <any>init;
    } // ctor
  } // class

  angular
    .module('powur.core')
    .filter(DecimalPartFilter.FilterId, <any>DecimalPartFilter);
}
