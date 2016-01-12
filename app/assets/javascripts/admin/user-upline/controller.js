;(function() {
  'use strict';

  angular.module('powurApp')
    .controller('AdminUserUplineCtrl', controller)
    .config(routes);

  controller.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$anchorScroll', '$http', 'Utility'];
  function controller($scope, $rootScope, $location, $routeParams, $anchorScroll, $http, Utility) {
    $scope.redirectUnlessSignedIn();

    $rootScope.breadcrumbs.push({title: 'Users', href: '/admin/users'});

    getUser($routeParams.userId, function(item) {
      $scope.user = item;
      $scope.actions = item.actions;

      $rootScope.breadcrumbs.push({title: $scope.fullName(item), href: '/admin/users/' + item.properties.id});

      $rootScope.breadcrumbs.push({title: 'Hierarchy'});
      // Get upline
      $scope.uplinePath = Utility.findBranch(
        item.entities, {'rel': 'user-ancestors'}).href;
      $http({
        method: 'GET',
        url: $scope.uplinePath
      }).success(function(data) {
        $scope.upline = data;
        $anchorScroll();
      });

      // Get downline
      $scope.downlinePath = Utility.findBranch(
        item.entities, {'rel': 'user-children'}).href;
      $http({
        method: 'GET',
        url: $scope.downlinePath
      }).success(function(data) {
        $scope.downline = data;
        $anchorScroll();
      });
    });

    $scope.fullName = function(user) {
      if (!user) return;
      return user.properties.first_name + ' ' + user.properties.last_name;
    };

    $scope.isSponsor = function(user) {
      return $scope.user.properties.sponsor_id === user.properties.id;
    };

    $scope.makeASponsor = function(user) {
      var sponsor_id = user.properties.id,
          action = Utility.findBranch($scope.actions, {'name': 'update_sponsor'});
      if (!action) return;

      $http({
        method: action.method,
        url: action.href,
        data: {
          sponsor_id: sponsor_id
        }
      }).success(function success(data) {
        if (data.error) {
        } else {
          $scope.user.properties.sponsor_id = sponsor_id;
        }
      });
    };

    function getUser(userId, cb) {
      $http({
        url: '/a/users/' + userId
      }).success(cb);
    }
  }

  /*
   * Routes
   */
  routes.$inject = ['$routeProvider'];
  function routes($routeProvider) {
    $routeProvider.
    when('/admin/users/:userId/hierarchy', {
      templateUrl: 'admin/user-upline/templates/index.html',
      controller: 'AdminUserUplineCtrl'
    });
  }

})();
