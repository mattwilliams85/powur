;(function() {
  'use strict';

  angular.module('powurApp')
    .controller('AdminUserOverridesCtrl', controller)
    .config(routes);

  controller.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$anchorScroll', '$http', 'Utility'];
  function controller($scope, $rootScope, $location, $routeParams, $anchorScroll, $http, Utility) {
    $scope.redirectUnlessSignedIn();

    $scope.templateData = {
      index: {
        title: 'Overrides',
        links: [
          { href: '/admin/users/' + $routeParams.userId + '/overrides/new', text: 'Add Rank Override' }
        ],
        tablePath: 'admin/user-overrides/templates/table.html'
      },
      new: {
        title: 'New Rank Override',
        formPath: 'admin/user-overrides/templates/form.html'
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

    $scope.overrideValue = function(override) {
      var data = override.properties.data;
      if (!data) return;

      switch (override.properties.kind) {
        case 'pay_as_rank':
          return data.rank;
          break;
      }
    }

    this.init($scope, $location);
    this.fetch($scope, $rootScope, $routeParams, $http, Utility);
  }

  controller.prototype.init = function($scope, $location) {
    $scope.mode = 'index';
    if (/\/new$/.test($location.path())) return $scope.mode = 'new';
  };

  controller.prototype.fetch = function($scope, $rootScope, $routeParams, $http, Utility) {
    $rootScope.breadcrumbs.push({title: 'Users', href: '/admin/users'});

    getUser($routeParams.userId, function(item) {
      $scope.user = item;
      $scope.actions = item.actions;

      $rootScope.breadcrumbs.push({title: $scope.fullName(item), href: '/admin/users/' + item.properties.id});

      if ($scope.mode === 'index') {
        $rootScope.breadcrumbs.push({title: 'Overrides'});
        $scope.indexPath = Utility.findBranch(
          item.entities, {'rel': 'user-overrides'}).href;
        $scope.index = {};
        $scope.pagination();
      } else if ($scope.mode === 'new') {
        $rootScope.breadcrumbs.push({title: 'Overrides', href: '/admin/users/' + item.properties.id + '/overrides'});
        $rootScope.breadcrumbs.push({title: 'New Rank Override'});
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
    when('/admin/users/:userId/overrides', {
      templateUrl: 'shared/admin/rest/index.html',
      controller: 'AdminUserOverridesCtrl'
    }).
    when('/admin/users/:userId/overrides/new', {
      templateUrl: 'shared/admin/rest/new.html',
      controller: 'AdminUserOverridesCtrl'
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
