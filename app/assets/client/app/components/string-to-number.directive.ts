/// <reference path='../../typings/tsd.d.ts' />

module powur {
  class StringToNumberDirective {
    static DirectiveId: string = 'pwStringToNumber';
    static $inject: Array<string> = [];

    constructor() {
      function link(scope: ng.IScope, element: JQuery, attrs: any, ngModel: any) {
        ngModel.$parsers.push(function(value: string) {
          return '' + value;
        });
        ngModel.$formatters.push(function(value: string) {
          return parseFloat(value);
        });
      }

      return <any>{
        require: 'ngModel',
        link: link
      };
    }
  }

  angular
    .module('powur.components')
    .directive(StringToNumberDirective.DirectiveId, <any>StringToNumberDirective);
}
