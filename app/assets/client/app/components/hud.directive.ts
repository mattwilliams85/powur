/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../../typings/references.d.ts' />

module powur.directives {
    class HudDirective {
        public static DirectiveId: string = 'pwHud';
        public static $inject: Array<string> = ['$log'];
        
        constructor(private $log: ng.ILogService) {
            return <any>{
                restrict: 'A',
                controller: 'HudController as hud',
                templateUrl: 'app/components/hud.html'
            }; // return
        } // ctor
    } // class
    
    directiveModule.directive(HudDirective.DirectiveId, <any>HudDirective);
}
