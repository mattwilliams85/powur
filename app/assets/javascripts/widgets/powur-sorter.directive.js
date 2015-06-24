;(function() {
  'use strict';

  function powurSorter($http) {
    function link(scope, element, attrs) {
      scope.sort = function() {
        if (!this.control || !this.control.links) return;

        var self = this,
            link = getLink(this.control.links);

        $http({
          method: 'GET',
          url: link.href,
          params: {
            sort: this.field
          },
          type: 'application/json'
        }).success(function(data) {
          self.control = data;
        }).error(function(err) {
          console.log('Sort request error', err);
        });
      };

      scope.iconCSSClass = scope.field.match(/\_desc/i) ?
        'fa-sort-desc' :
        'fa-sort-asc';
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
      '<a ng-click="sort()"><i class="fa {{iconCSSClass}}"></i></a>'
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
