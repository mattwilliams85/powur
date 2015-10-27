/// <reference path='../../typings/tsd.d.ts' />

module powur {
  class ScrolledDirective {
    static DirectiveId: string = 'pwScrolled';
    static $inject: Array<string> = ['$log'];

    root: IRootController;

    constructor($log: ng.ILogService) {
      this.root = RootController.get();

      function loadMore(entity) {
        var opts = { page: entity.properties.paging.current_page + 1 };
        if (entity.properties.filters) {
          for (var key in entity.properties.filters) {
            opts[key] = entity.properties.filters[key];
          }
        }

        this.root.$session.getEntity(
          SirenModel,
          entity.rel[0],
          opts,
          true
        ).then((data: any) => {
          entity.entities = entity.entities.concat(data.entities);
          entity.properties = data.properties;
        });
      }

      return <any>{
        link: function(scope: ng.IScope, element: JQuery, attributes: any) {
          var raw = element[0];

          element.bind('scroll', function() {
            if (raw.scrollTop + raw.offsetHeight >= raw.scrollHeight) {
              loadMore(scope.$apply(attributes.pwScrolled));
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
