;(function() {
  'use strict';

  angular.module('powurApp')
    .controller('AdminUserUplineCtrl', controller)
    .config(routes);

  controller.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$anchorScroll', '$http', 'Utility'];
  function controller($scope, $rootScope, $location, $routeParams, $anchorScroll, $http, Utility) {
    $scope.redirectUnlessSignedIn();

    $scope.templateData = {
      index: {
        title: 'Users',
        tablePath: 'admin/user-upline/templates/table.html'
      }
    };

    $scope.indexPath = '';

    $scope.pagination = function(direction, path) {
      if (typeof direction === 'undefined') direction = 0;
      if (typeof path === 'undefined') path = $scope.indexPath;
      var params = {
            page: 1
          };
      if ($scope.index.data) {
        params.page = $scope.index.data.properties.paging.current_page;
        params.sort = $scope.index.data.properties.sorting.current_sort;
      }
      params.page += direction;

      return $http({
        method: 'GET',
        url: path,
        params: params
      }).success(function(data) {
        $scope.index.data = data;
        $anchorScroll();
      });
    };

    $scope.fullName = function(user) {
      if (!user) return;
      return user.properties.first_name + ' ' + user.properties.last_name;
    };

    this.init($scope, $location);
    this.fetch($scope, $rootScope, $routeParams, $http, Utility);
  }

  controller.prototype.init = function($scope, $location) {
    $scope.mode = 'upline';
    if (/\/downline$/.test($location.path())) return $scope.mode = 'downline';
  };

  controller.prototype.fetch = function($scope, $rootScope, $routeParams, $http, Utility) {
    $rootScope.breadcrumbs.push({title: 'Users', href: '/admin/users'});

    getUser($routeParams.userId, function(item) {
      $scope.user = item;
      $scope.actions = item.actions;

      $rootScope.breadcrumbs.push({title: $scope.fullName(item), href: '/admin/users/' + item.properties.id});

      if ($scope.mode === 'upline') {
        $rootScope.breadcrumbs.push({title: 'Upline'});
        $scope.templateData.index.title = 'Upline Users'
        $scope.indexPath = Utility.findBranch(
          item.entities, {'rel': 'user-ancestors'}).href;
        $scope.index = {};
        $scope.pagination();
      } else if ($scope.mode === 'downline') {
        $rootScope.breadcrumbs.push({title: 'Downline'});
        $scope.templateData.index.title = 'Downline Users'
        $scope.indexPath = Utility.findBranch(
          item.entities, {'rel': 'user-children'}).href;
        $scope.index = {};
        $scope.pagination();
      }
    });

    function getUser(userId, cb) {
      $http({
        url: '/a/users/' + userId
      }).success(cb);
    }
  };

  /*
   * Routes
   */
  routes.$inject = ['$routeProvider'];
  function routes($routeProvider) {
    $routeProvider.
    when('/admin/users/:userId/upline', {
      templateUrl: 'shared/admin/rest/index.html',
      controller: 'AdminUserUplineCtrl'
    }).
    when('/admin/users/:userId/downline', {
      templateUrl: 'shared/admin/rest/index.html',
      controller: 'AdminUserUplineCtrl'
    });
  }

  /*
   * Utility Functions
   */
  function getAction(actions, name) {
    for (var i in actions) {
      if (actions[i].name === name) {
        return actions[i];
      }
    }
  }

})();
