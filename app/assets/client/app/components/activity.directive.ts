/// <reference path='../_references.ts' />

module powur {
  class ActivityDirective {
    static DirectiveId: string = 'pwActivity';
    static $inject: Array<string> = ['$log'];
    
    constructor($log: ng.ILogService) {
      return <any>{
        restrict: 'A',
        controller: 'ActivityController as activity',
        templateUrl: 'app/components/activity.html'
      }; // return
    } // ctor
  } // class
  
  directiveModule.directive(ActivityDirective.DirectiveId, <any>ActivityDirective);
}
