/// <reference path='../../typings/tsd.d.ts' />

module powur {
    class FocusDirective {
        static DirectiveId: string = 'focusIf';
        static $inject: Array<string> = ['$timeout'];

        constructor($timeout: ng.ITimeoutService) {
                function link($scope, $element, $attrs) {
                    var elem = $element[0];
                    if ($attrs.focusIf) {
                        $scope.$watch($attrs.focusIf, focus);
                    } else {
                        focus(true);
                    }
                    function focus(condition) {
                        if (condition) {
                            $timeout(function() {
                                elem.focus();
                            }, $scope.$eval($attrs.focusDelay) || 0);
                        }
                    }
                }
                return {
                    restrict: 'A',
                    link: link
                };
        } // ctor
    } // class

    angular
        .module('powur.components')
        .directive(FocusDirective.DirectiveId, <any>FocusDirective);
}
