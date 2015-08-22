;(function() {
  'use strict';

  angular.module('powurApp')
    .controller('AdminPayPeriodsCtrl', controller)
    .config(routes);

  controller.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$anchorScroll', '$http', 'Utility'];
  function controller($scope, $rootScope, $location, $routeParams, $anchorScroll, $http, Utility) {
    $scope.redirectUnlessSignedIn();
    $scope.sum = 0;

    $scope.templateData = {
      index: {
        title: 'Pay Periods',
        tablePath: 'admin/pay-periods/templates/table.html'
      },
      show: {
        title: 'Pay Period',
        tablePath: 'admin/pay-periods/templates/users.html'
      },
      bonuses: {
        title: 'Users',
        tablePath: 'admin/pay-periods/templates/bonuses.html'
      }
    };

    $scope.payPeriodFilters = [ { value: 'monthly', title: 'Monthly' },
                                { value: 'weekly', title: 'Weekly' } ];

    // TODO: Have one 'pagination' function instead of defining it in every controller
    $scope.pagination = function(direction, path) {
      if (typeof direction === 'undefined') direction = 0;
      if (typeof path === 'undefined') path = '/u/pay_periods';
      var page = 1,
          sort,
          time_span;
      if ($scope.index.data) {
        page = $scope.index.data.properties.paging.current_page;
        sort = $scope.index.data.properties.sorting.current_sort;
        time_span = $scope.index.data.selectedFilter;
      }
      page += direction;

      return $http({
        method: 'GET',
        url: path,
        params: {
          page: page,
          sort: sort,
          time_span: time_span
        }
      }).success(function(data) {
        $scope.index.data = data;
        $scope.index.data.selectedFilter = time_span;
        $anchorScroll();
      });
    };

    $scope.withPayPeriod = function(id, cb) {
      return $http({
        method: 'GET',
        url: '/u/pay_periods/' + id
      }).success(cb);
    };

    $scope.forUser = function(ppId, userId, cb) {
      $scope.payPeriod = ppId;
      return $http({
        method: 'GET',
        url: '/u/pay_periods/' + ppId + '/users/' + userId + '.json'
      }).success(cb);
    };

    $scope.executeAction = function(action) {
      return $http({
        method: action.method,
        url: action.href,
      }).success(function(data) {
        $scope.payPeriod = data.properties;
        $scope.buttonActions = data.actions;
      });
    };

    $scope.cancel = function() {
      $location.path('/admin/pay-periods');
    };

    this.init($scope, $location);
    this.fetch($scope, $rootScope, $location, $routeParams, Utility);
  }

  controller.prototype.init = function($scope, $location) {
    $scope.mode = 'index';
    if (/\/bonuses/.test($location.path())) return $scope.mode = 'bonuses';
    if (/\/pay-periods\//.test($location.path())) return $scope.mode = 'show';
  };

  controller.prototype.fetch = function($scope, $rootScope, $location, $routeParams, Utility) {
    $scope.index = {};

    if ($scope.mode === 'index') {
      $rootScope.breadcrumbs.push({title: $scope.templateData.index.title});
      $scope.pagination();
    } else if ($scope.mode === 'show') {
      $scope.withPayPeriod($routeParams.payPeriodId, function(data) {
        $scope.payPeriod = data.properties;
        $scope.buttonActions = data.actions;
        $scope.templateData.show.title = data.properties.title;
        $rootScope.breadcrumbs.push({title: $scope.templateData.index.title, href:'/admin/pay-periods'});
        $rootScope.breadcrumbs.push({title: data.properties.id});

        var entity = findByRel('pay_period-users', data.entities);
        $scope.pagination(0, entity.href);
      });
    } else if ($scope.mode === 'bonuses') {
      $scope.forUser($routeParams.payPeriodId, $routeParams.userId, function(data) {
        $rootScope.breadcrumbs.push({title: $scope.templateData.index.title, href:'/admin/pay-periods'});
        $rootScope.breadcrumbs.push({title: $scope.payPeriod, href:'/admin/pay-periods/'+ $scope.payPeriod});
        $rootScope.breadcrumbs.push({title: data.properties.id});

        $scope.user = data.properties;
        $scope.leadTotals = Utility.findBranch(
          data.entities, {'rel': 'user-lead_totals'}).entities;
        $scope.bonuses = Utility.findBranch(
          data.entities, {'rel': 'user-bonus_payments'}).entities;
        for (var b in $scope.bonuses) {
          $scope.sum += parseInt($scope.bonuses[b].properties.amount);
        }
      });
    }
  };

  routes.$inject = ['$routeProvider'];
  function routes($routeProvider) {
    $routeProvider.
    when('/admin/pay-periods/:payPeriodId/users/:userId/bonuses', {
      templateUrl: 'admin/pay-periods/templates/bonuses.html',
      controller: 'AdminPayPeriodsCtrl'
    }).
    when('/admin/pay-periods', {
      templateUrl: 'shared/admin/rest/index.html',
      controller: 'AdminPayPeriodsCtrl'
    }).
    when('/admin/pay-periods/:payPeriodId', {
      templateUrl: 'shared/admin/rest/show.html',
      controller: 'AdminPayPeriodsCtrl'
    });
  }

  // Utility Functions
  function findByRel(rel, items) {
    for (var i in items) {
      for (var j in items[i].rel) {
        if (items[i].rel[j] === rel) {
          return items[i];
        }
      }
    }
  }

})();
