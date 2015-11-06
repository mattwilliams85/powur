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

    // $scope.updateAvailableInvites = function(item) {
    //   $http({
    //     method: 'PATCH',
    //     url: '/a/users/' + item.properties.id + '/invites.json',
    //     data: {
    //       invites: item.properties.available_invites
    //     }
    //   }).success(function(data) {
    //     if (data.error) {
    //       $scope.showModal('There was an error updating this user\'s available invites.');
    //     }
    //     item.properties.lifetime_invites_count = data.properties.lifetime_invites_count;
    //   });
    // };

    this.init($scope, $location);
    this.fetch($scope, $rootScope);
  }

  controller.prototype.init = function($scope, $location) {
    $scope.mode = 'pending';
    if (/\/available/.test($location.path())) return $scope.mode = 'available';
  };

  controller.prototype.fetch = function($scope, $rootScope) {
    if ($scope.mode === 'pending') {
      $rootScope.breadcrumbs.push({title: 'Pending Invites'});
      $scope.index = {};
      $scope.pagination(0, $scope.listPath = '/a/invites?pending=true');
    } else if ($scope.mode === 'available') {
      $rootScope.breadcrumbs.push({title: 'Available Invites'});
      $scope.index = {};
      $scope.pagination(0, $scope.listPath = '/a/users/invites?with_purchases=false');
    }
  };

  routes.$inject = ['$routeProvider'];
  function routes($routeProvider) {
    $routeProvider.
    when('/admin/invites/pending', {
      templateUrl: 'admin/invites/templates/pending.html',
      controller: 'AdminInvitesCtrl'
    }).
    when('/admin/invites/available', {
      templateUrl: 'admin/invites/templates/available.html',
      controller: 'AdminInvitesCtrl'
    });
  }

})();
