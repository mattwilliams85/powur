/// <reference path='../../typings/tsd.d.ts' />

module powur {
  class HudDirective {
    static DirectiveId: string = 'pwHud';
    static $inject: Array<string> = ['$log'];
    
    constructor($log: ng.ILogService) {
      return <any>{
        restrict: 'A',
        scope: {
          home: '=pwHud'
        },
        controller: 'HudController as hud',
        templateUrl: 'app/layout/hud.html'
      }; // return
    } // ctor
  } // class

  angular
    .module('powur.layout')
    .directive(HudDirective.DirectiveId, <any>HudDirective);
}
