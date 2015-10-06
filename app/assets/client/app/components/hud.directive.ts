/// <reference path='../_references.ts' />

module powur {
    class HudDirective {
        public static DirectiveId: string = 'pwHud';
        public static $inject: Array<string> = ['$log'];
        
        constructor($log: ng.ILogService) {
            return <any>{
                restrict: 'A',
                controller: 'HudController as hud',
                templateUrl: 'app/components/hud.html'
            }; // return
        } // ctor
    } // class
    
    directiveModule.directive(HudDirective.DirectiveId, <any>HudDirective);
}
