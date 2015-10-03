/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../../typings/references.d.ts' />

module powur.directives {
    class NavDirective {
        public static DirectiveId: string = 'pwNav';
        public static $inject: Array<string> = ['$log'];
        
        constructor(private $log: ng.ILogService) {
            return <any>{
                restrict: 'A',
                controller: 'NavController as nav',
                templateUrl: 'app/components/nav.html'
            }; // return
        } // ctor
    } // class
    
    directiveModule.directive(NavDirective.DirectiveId, <any>NavDirective);
}
