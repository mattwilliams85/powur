;(function() {
  'use strict';

  angular.module('powurApp')
    .controller('AdminInvitesCtrl', controller)
    .config(routes);

  controller.$inject = ['$scope', '$rootScope', '$location', '$anchorScroll', '$http', '$timeout', 'CommonService'];
  function controller($scope, $rootScope, $location, $anchorScroll, $http, $timeout, CommonService) {
    $scope.redirectUnlessSignedIn();
    $scope.search = {};

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
          search: $scope.search.string
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

    this.init($scope, $location);
    this.fetch($scope, $rootScope);
  }

  controller.prototype.init = function($scope, $location) {
    $scope.mode = 'pending';
  };

  controller.prototype.fetch = function($scope, $rootScope) {
    $rootScope.breadcrumbs.push({title: 'Grid Invites'});
    $scope.index = {};
    $scope.pagination(0, $scope.listPath = '/a/invites?pending=true');
  };

  routes.$inject = ['$routeProvider'];
  function routes($routeProvider) {
    $routeProvider.
    when('/admin/invites/pending', {
      templateUrl: 'admin/invites/templates/pending.html',
      controller: 'AdminInvitesCtrl'
    });
  }

})();
