/// <reference path='../../typings/tsd.d.ts' />

module powur {
    class TitleDirective {
        static DirectiveId: string = 'pwTitle';
        static $inject: Array<string> = ['$rootScope', '$log', '$timeout'];

        constructor($rootScope: ng.IRootScopeService, $log: ng.ILogService, $timeout: ng.ITimeoutService) {

            function capitalizeFirstLetter(string) {
                return string.charAt(0).toUpperCase() + string.slice(1);
            }

            return <any>{
                link: function(scope: ng.IScope, element: JQuery) {
                   var listener = function(event, toState) {

                    var title = 'Welcome to Powur';
                    if (toState.params && toState.params.title) title = toState.params.title;

                    title = capitalizeFirstLetter(title);
                    $timeout(function() {
                      element.text(title);
                    }, 0, false);
                  };

                  $rootScope.$on('$stateChangeSuccess', listener);
                }
            }; // return
        } // ctor
    } // class

    angular
        .module('powur.components')
        .directive(TitleDirective.DirectiveId, <any>TitleDirective);
}
