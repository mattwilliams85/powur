/// <reference path='../../typings/tsd.d.ts' />

module powur {
  class WholeNumberFilter {
    static FilterId: string = 'wholeNumber';
    static $inject: Array<string> = ['$log'];
    
    constructor(private $log: ng.ILogService) {
      var toCommas = (v: number): string => {
        return v.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
      };
      
      var init = (input: number, withCommas: boolean = true): string => {
        var v = Math.floor(input);
        return withCommas ? toCommas(v) : v.toString();
      };
      
      return <any>init;
    } // ctor
  } // class

  angular
    .module('powur.core')
    .filter(WholeNumberFilter.FilterId, <any>WholeNumberFilter);
}
