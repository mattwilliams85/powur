/// <reference path='../../typings/tsd.d.ts' />

module powur {
  class ScrolledDirective {
    static DirectiveId: string = 'pwScrolled';
    static $inject: Array<string> = ['$log', '$window'];

    root: IRootController;
    history: any;

    constructor($log: ng.ILogService, $window: any) {
      this.root = RootController.get();
      this.history = {};

      function loadMore(entity, scope) {
        var pg = entity.properties.paging.current_page;

        if (pg === this.history.page && entity.rel === this.history.rel) return;
        this.history = { page: pg, rel: entity.rel[0] };
        var opts = { page: pg + 1 };
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
          if (!data.entities.length) return;
          entity.entities = entity.entities.concat(data.entities);
          entity.properties = data.properties;
          setTimeout(function() {
              scope.invite.buildPies();
          })
        });
      }

      return <any>{
        link: function(scope: any, element: JQuery, attributes: any) {
          var raw = element[0];
          var loading;
          angular.element($window).bind('scroll', function() {
            if (angular.element($window).scrollTop() + angular.element($window).height() > $(document).height() - 100 && !loading) {
                loading = true;
                setTimeout(function(){
                  loading = false;
                  loadMore(scope.$apply(attributes.pwScrolled), scope);
                  
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
