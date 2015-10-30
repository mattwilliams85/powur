/// <reference path='../../typings/tsd.d.ts' />

module powur {
  class ScrolledDirective {
    static DirectiveId: string = 'pwScrolled';
    static $inject: Array<string> = ['$log', '$window'];

    root: IRootController;

    constructor($log: ng.ILogService, $window: any) {
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
          var loading;
          angular.element($window).bind('scroll', function() {
            if (angular.element($window).scrollTop() + angular.element($window).height() > $(document).height() - 100 && !loading) {
                loading = true;
                setTimeout(function(){
                  loading = false;
                  loadMore(scope.$apply(attributes.pwScrolled));
                }, 500);
              
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
