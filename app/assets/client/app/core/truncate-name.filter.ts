/// <reference path='../../typings/tsd.d.ts' />

module powur {
  class TruncateNameFilter {
    static FilterId: string = 'truncateName';
    static $inject: Array<string> = ['$log', '$window'];
    
    constructor(private $log: ng.ILogService, private $window: ng.IWindowService) {
      var init = (input: string): string => {
        var deviceWidth = ($window.innerWidth > 0) ? $window.innerWidth : screen.width;
        var v = input;
        if (deviceWidth < 720 || input.length >= 7) v = input[0] + ".";
        return v;
      };
      
      return <any>init;
    } // ctor
  } // class

  angular
    .module('powur.core')
    .filter(TruncateNameFilter.FilterId, <any>TruncateNameFilter);
}
