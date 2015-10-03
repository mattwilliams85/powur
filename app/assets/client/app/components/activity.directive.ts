/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../../typings/references.d.ts' />

module powur.directives {
    class ActivityDirective {
        public static DirectiveId: string = 'pwActivity';
        public static $inject: Array<string> = ['$log'];
        
        constructor(private $log: ng.ILogService) {
            return <any>{
                restrict: 'A',
                controller: 'ActivityController as activity',
                templateUrl: 'app/components/activity.html'
            }; // return
        } // ctor
    } // class
    
    directiveModule.directive(ActivityDirective.DirectiveId, <any>ActivityDirective);
}
