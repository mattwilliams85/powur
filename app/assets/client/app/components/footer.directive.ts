/// <reference path='../../typings/tsd.d.ts' />

module powur {
  class FooterDirective {
    static DirectiveId: string = 'pwFooter';
    static $inject: Array<string> = [];

    constructor() {
      return <any>{
        restrict: 'E',
        templateUrl: 'app/components/footer.html'
      };
    }
  }

  angular
    .module('powur.components')
    .directive(FooterDirective.DirectiveId, <any>FooterDirective);
}
