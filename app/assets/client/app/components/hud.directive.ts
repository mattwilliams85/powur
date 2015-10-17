/// <reference path='../_references.ts' />

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
        templateUrl: 'app/components/hud.html'
      }; // return
    } // ctor
  } // class
  
  directiveModule.directive(HudDirective.DirectiveId, <any>HudDirective);
}
