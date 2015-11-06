/// <reference path='../../typings/tsd.d.ts' />

module powur {
  class NavDirective {
    static DirectiveId: string = 'pwNav';
    static $inject: Array<string> = ['$log'];
    
    constructor($log: ng.ILogService) {
      return <any>{
        restrict: 'A',
        scope: {
          home: '=pwNav'
        },
        controller: 'NavController as nav',
        templateUrl: 'app/layout/nav.html'
      }; // return
    } // ctor
  } // class

  angular
    .module('powur.layout')
    .directive(NavDirective.DirectiveId, <any>NavDirective);
}
