/// <reference path='../../typings/tsd.d.ts' />

module powur {
    class FocusDirective {
        static DirectiveId: string = 'pwFocusOnShow';
        static $inject: Array<string> = ['$timeout'];

        constructor($timeout: ng.ITimeoutService) {

            return {
                restrict: 'A',
                link: function($scope, $element, $attr) {
                    if ($attr.ngShow){
                        $scope.$watch($attr.ngShow, function(newValue){
                            if(newValue){
                                $timeout(function(){
                                    $element.focus();
                                }, 0);
                            }
                        })      
                    }
                    if ($attr.ngHide){
                        $scope.$watch($attr.ngHide, function(newValue){
                            if(!newValue){
                                $timeout(function(){
                                    $element.focus();
                                }, 0);
                            }
                        })      
                    }

                }
            };
        } // ctor
    } // class

    angular
        .module('powur.components')
        .directive(FocusDirective.DirectiveId, <any>FocusDirective);
}

