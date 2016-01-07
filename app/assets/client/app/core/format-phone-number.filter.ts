/// <reference path='../../typings/tsd.d.ts' />

module powur {
  class formatPhoneNumber {
    static FilterId: string = 'formatPhoneNumber';
    static $inject: Array<string> = ['$log', '$window'];

    constructor(private $log: ng.ILogService, private $window: ng.IWindowService) {
      var init = (input: string): string => {
        var re = /\(?(\d{3})\)?[- ]?(\d{3})[- ]?(\d{4})/g; 
        var subst = '($1) $2-$3'; 

        return input.replace(re, subst); 
      };

      return <any>init;
    } // ctor
  } // class

  angular
    .module('powur.core')
    .filter(formatPhoneNumber.FilterId, <any>formatPhoneNumber);
}
