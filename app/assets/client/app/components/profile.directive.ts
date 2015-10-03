/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../../typings/references.d.ts' />

module powur.directives {
    class ProfileDirective {
        public static DirectiveId: string = 'pwProfile';
        public static $inject: Array<string> = ['$log'];
        
        constructor(private $log: ng.ILogService) {
            return <any>{
                restrict: 'A',
                controller: 'ProfileController as profile',
                templateUrl: 'app/components/profile.html'
            }; // return
        } // ctor
    } // class
    
    directiveModule.directive(ProfileDirective.DirectiveId, <any>ProfileDirective);
}
