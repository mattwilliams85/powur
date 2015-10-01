;(function() {
  'use strict';

  angular.module('powurApp')
    .controller('AdminUserOverridesCtrl', controller)
    .config(routes);

  controller.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$anchorScroll', '$http', '$timeout', 'Utility'];
  function controller($scope, $rootScope, $location, $routeParams, $anchorScroll, $http, $timeout, Utility) {
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

    $scope.kinds = [
      { title: 'Pay As Rank', value: 'pay_as_rank' }
    ];

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

    $scope.cancel = function() {
      $location.path('/admin/users/' + $scope.user.properties.id + '/overrides');
    };

    $scope.create = function() {
      if ($scope.override) {
        $scope.isSubmitDisabled = true;
        $http({
          method: 'POST',
          url: $scope.indexPath,
          data: $scope.override
        }).success(function(data) {
          $scope.isSubmitDisabled = false;
          $location.path('/admin/users/' + $scope.user.properties.id + '/overrides');
          $scope.showModal('Override successfully created');
        }).error(function error(data) {
          $scope.isSubmitDisabled = false;
          $scope.showModal('There was an error while creating an override.');
        });
      }
    };

    $scope.delete = function(item) {
      var action = getAction(item.actions, 'delete');
      return $http({
        method: action.method,
        url: action.href
      }).success(function() {
        $scope.showModal('This item has been deleted.');
        $scope.index = {};
        $scope.pagination(0);
      }).error(function() {
        $scope.showModal('Oops, error while deleting');
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
    };

    $scope.confirm = function(msg, clickAction, arg) {
      if (window.confirm(msg)) {
        return $scope.$eval(clickAction)(arg);
      }
    };

    this.init($scope, $location);
    this.fetch($scope, $rootScope, $routeParams, $http, $timeout, Utility);
  }

  controller.prototype.init = function($scope, $location) {
    $scope.mode = 'index';
    if (/\/new$/.test($location.path())) return $scope.mode = 'new';
  };

  controller.prototype.fetch = function($scope, $rootScope, $routeParams, $http, $timeout, Utility) {
    $rootScope.breadcrumbs.push({title: 'Users', href: '/admin/users'});

    getUser($routeParams.userId, function(item) {
      $scope.user = item;
      $scope.actions = item.actions;

      $rootScope.breadcrumbs.push({title: $scope.fullName(item), href: '/admin/users/' + item.properties.id});

      $scope.indexPath = Utility.findBranch(
        item.entities, {'rel': 'user-overrides'}).href;

      if ($scope.mode === 'index') {
        $rootScope.breadcrumbs.push({title: 'Overrides'});
        $scope.index = {};
        $scope.pagination();
      } else if ($scope.mode === 'new') {
        $rootScope.breadcrumbs.push({title: 'Overrides', href: '/admin/users/' + item.properties.id + '/overrides'});
        $rootScope.breadcrumbs.push({title: 'New Rank Override'});
        getRanks(function(data) {
          $scope.ranks = data.entities;
          $scope.override = {
            kind: $scope.kinds[0].value,
            value: data.entities[0].properties.id
          };
        });

        $timeout(function() {
          var format = 'yy-mm-dd';
          $('#override_start_date').datepicker({
            dateFormat: format
          });
          $('#override_end_date').datepicker({
            dateFormat: format
          });
        });
      }
    });

    function getUser(userId, cb) {
      $http({
        url: '/a/users/' + userId
      }).success(cb);
    }

    function getRanks(cb) {
      $http({
        url: '/u/ranks'
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
