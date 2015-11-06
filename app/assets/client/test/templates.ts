/// <reference path='../typings/tsd.d.ts' />
angular.module("templates", []);

angular.module("templates").run(["$templateCache", ($templateCache: ng.ITemplateCacheService) => {
  $templateCache.put("app/layout/nav.html", '')
}]);
