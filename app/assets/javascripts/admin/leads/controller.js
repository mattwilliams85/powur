;(function() {
  'use strict';

  angular.module('powurApp')
    .controller('AdminLeadsCtrl', controller)
    .config(routes);

  controller.$inject = ['$scope', '$rootScope', '$anchorScroll', '$http', 'CommonService', '$timeout'];
  function controller($scope, $rootScope, $anchorScroll, $http, CommonService, $timeout) {
    $scope.redirectUnlessSignedIn();
    $scope.search = {};

    $scope.templateData = {
      index: {
        title: 'Leads',
        tablePath: 'admin/leads/templates/table.html'
      }
    };

    // TODO: Have one 'pagination' function instead of defining it in every controller
    $scope.pagination = function(direction, path) {
      var page = 1,
          sort;
      if ($scope.index.data) {
        page = $scope.index.data.properties.paging.current_page;
        sort = $scope.index.data.properties.sorting.current_sort;
      }
      page += direction;
      if (!direction) page = 1;

      return $http({
        method: 'GET',
        url: path || $scope.listPath,
        params: {
          page: page,
          sort: sort,
          limit: 10,
          user_search: $scope.search.string
        }
      }).success(function(data) {
        $scope.index.data = data;
        $anchorScroll();
      });
    };

    $scope.clearSearch = function() {
      $timeout(function(){
        if (!$scope.search.string) {
          $scope.pagination();
        }
      });
    };

    $scope.index = {};

    $rootScope.breadcrumbs.push({title: $scope.templateData.index.title});
    $scope.pagination(0, $scope.listPath = '/u/leads');
  }



  routes.$inject = ['$routeProvider'];
  function routes($routeProvider) {
    $routeProvider.
    when('/admin/leads', {
      templateUrl: 'shared/admin/rest/index.html',
      controller: 'AdminLeadsCtrl'
    });
  }

})();
