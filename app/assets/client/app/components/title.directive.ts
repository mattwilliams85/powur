/// <reference path='../../typings/tsd.d.ts' />

module powur {
  class TitleDirective {
    static DirectiveId: string = 'pwTitle';
    static $inject: Array<string> = ['$rootScope', '$timeout'];

    constructor($rootScope: ng.IRootScopeService, $timeout: ng.ITimeoutService) {

      function capitalizeFirstLetter(string) {
        return string.charAt(0).toUpperCase() + string.slice(1);
      }

      function htmlToPlainText(text) {
        return String(text).replace(/<[^>]+>/gm, '');
      }

      function link(scope: ng.IScope, element: JQuery) {
        $rootScope.$on('$stateChangeSuccess', function listener(event, toState) {
          var title = 'Welcome to Powur';

          if (toState.params && toState.params.title) {
            title = capitalizeFirstLetter(htmlToPlainText(toState.params.title));
          }

          $timeout(function() {
            element.text(title);
          }, 0, false);
        });
      }

      return <any>{
        link: link
      };
    }
  }

  angular
    .module('powur.components')
    .directive(TitleDirective.DirectiveId, <any>TitleDirective);
}
