/// <reference path='../_references.ts' />

module powur {
    class NavDirective {
        static DirectiveId: string = 'pwNav';
        static $inject: Array<string> = ['$log'];
        
        constructor($log: ng.ILogService) {
            return <any>{
                restrict: 'A',
                controller: 'NavController as nav',
                templateUrl: 'app/components/nav.html'
            }; // return
        } // ctor
    } // class
    
    directiveModule.directive(NavDirective.DirectiveId, <any>NavDirective);
}
