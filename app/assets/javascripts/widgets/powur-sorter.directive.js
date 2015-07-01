;(function() {
  'use strict';

  function powurSorter($http) {
    function link(scope, element, attrs) {
      scope.currentSort = true;

      scope.sort = function() {
        if (!scope.control || !scope.control.links) return;

        var link = getLink(scope.control.links);

        $http({
          method: 'GET',
          url: link.href,
          params: {
            sort: scope.currentSort ? scope.field + '_asc' : scope.field + '_desc'
          },
          type: 'application/json'
        }).success(function(data) {
          scope.control = data;
          scope.currentSort = !scope.currentSort;
        }).error(function(err) {
          console.log('Sort request error', err);
        });
      };
    }

    var directive = {
      restrict: 'E',
      scope: {
        control: '=',
        field: '@'
      },
      templateUrl: 'templates/widgets/powur-sorter.html',
      link: link
    };

    return directive;
  }

  function powurSorterTemplate($templateCache) {
    $templateCache.put(
      'templates/widgets/powur-sorter.html',
      '<a ng-if="currentSort" ng-click="sort()"><i class="fa fa-sort-desc"></i></a>' +
      '<a ng-if="!currentSort" ng-click="sort()"><i class="fa fa-sort-asc"></i></a>'
    );
  }

  powurSorter.$inject = ['$http'];

  angular
    .module('widgets.powurSorter', [])
    .directive('powurSorter', powurSorter)
    .run(['$templateCache', powurSorterTemplate]);

  /**
   * Utility functions
   */
  function getLink(links) {
    for (var i in links) {
      if (links[i].rel === 'self') {
        return links[i];
      }
    }
    return;
  }

})();
