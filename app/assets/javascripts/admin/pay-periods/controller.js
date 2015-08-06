;(function() {
  'use strict';

  angular.module('powurApp')
    .controller('AdminPayPeriodsCtrl', controller)
    .config(routes);

  controller.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$anchorScroll', '$http'];
  function controller($scope, $rootScope, $location, $routeParams, $anchorScroll, $http) {
    $scope.redirectUnlessSignedIn();

    $scope.templateData = {
      index: {
        title: 'Pay Periods',
        tablePath: 'admin/pay-periods/templates/table.html'
      },
      show: {
        title: 'Pay Period',
        tablePath: 'admin/pay-periods/templates/users.html'
      }
    };

    $scope.payPeriodFilters = [ { value: 'monthly', title: 'Monthly' },
                                { value: 'weekly', title: 'Weekly' } ];

    // TODO: Have one 'pagination' function instead of defining it in every controller
    $scope.pagination = function(direction) {
      if (typeof direction === 'undefined') direction = 0;
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
        url: '/a/pay_periods',
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
        url: '/a/pay_periods/' + id
      }).success(cb);
    };

    $scope.cancel = function() {
      $location.path('/admin/pay-periods');
    };

    this.init($scope, $location);
    this.fetch($scope, $rootScope, $location, $routeParams);
  }

  controller.prototype.init = function($scope, $location) {
    $scope.mode = 'index';
    if (/\/pay-periods\//.test($location.path())) return $scope.mode = 'show';
  };

  controller.prototype.fetch = function($scope, $rootScope, $location, $routeParams) {
    if ($scope.mode === 'index') {
      $rootScope.breadcrumbs.push({title: $scope.templateData.index.title});
      $scope.index = {};
      $scope.pagination();
    } else if ($scope.mode === 'show') {
      $scope.withPayPeriod($routeParams.payPeriodId, function(item) {
        $scope.payPeriod = item.properties;
        $scope.templateData.show.title = item.properties.title;
        $rootScope.breadcrumbs.push({title: $scope.templateData.index.title, href:'/admin/pay-periods'});
        $rootScope.breadcrumbs.push({title: item.properties.id});
      });
    }
  };

  routes.$inject = ['$routeProvider'];
  function routes($routeProvider) {
    $routeProvider.
    when('/admin/pay-periods', {
      templateUrl: 'shared/admin/rest/index.html',
      controller: 'AdminPayPeriodsCtrl'
    }).
    when('/admin/pay-periods/:payPeriodId?', {
      templateUrl: 'shared/admin/rest/show.html',
      controller: 'AdminPayPeriodsCtrl'
    });
  }

})();
