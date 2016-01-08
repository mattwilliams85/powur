;(function() {
  'use strict';

  angular.module('powurApp')
    .controller('AdminInvitesCtrl', controller)
    .config(routes);

  controller.$inject = ['$scope', '$rootScope', '$location', '$anchorScroll', '$http'];
  function controller($scope, $rootScope, $location, $anchorScroll, $http) {
    $scope.redirectUnlessSignedIn();

    // TODO: Have one 'pagination' function instead of defining it in every controller
    $scope.pagination = function(direction, path) {
      if (typeof direction === 'undefined') direction = 0;
      var page = 1,
          sort;
      if ($scope.index.data) {
        page = $scope.index.data.properties.paging.current_page;
        sort = $scope.index.data.properties.sorting.current_sort;
      }
      page += direction;

      return $http({
        method: 'GET',
        url: path || $scope.listPath,
        params: {
          page: page,
          sort: sort,
          search: $scope.searchInvites
        }
      }).success(function(data) {
        $scope.index.data = data;
        $anchorScroll();
      });
    };

    $scope.search = function() {
      $scope.index = {};
      $scope.pagination();
    };

    this.init($scope, $location);
    this.fetch($scope, $rootScope);
  }

  controller.prototype.init = function($scope, $location) {
    $scope.mode = 'pending';
  };

  controller.prototype.fetch = function($scope, $rootScope) {
    $rootScope.breadcrumbs.push({title: 'Pending Invites'});
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
