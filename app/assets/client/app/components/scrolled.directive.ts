/// <reference path='../../typings/tsd.d.ts' />

module powur {
  class ScrolledDirective {
    static DirectiveId: string = 'pwScrolled';
    static $inject: Array<string> = ['$log'];

    constructor($log: ng.ILogService) {
      return <any>{
        link: function (scope: ng.IScope, element: JQuery, attributes: any) {
          var raw = element[0];

          element.bind('scroll', function() {
            if (raw.scrollTop + raw.offsetHeight >= raw.scrollHeight) {
              scope.$apply(attributes.pwScrolled);
            }
          });
        }
      };
    }
  }

  angular
    .module('powur.components')
    .directive(ScrolledDirective.DirectiveId, <any>ScrolledDirective);
}
