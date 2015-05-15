;(function() {
  'use strict';

  function AdminPayPeriodsCtrl($scope, $rootScope, $location, $routeParams, $anchorScroll, $http, AdminPayPeriod) {
    $scope.redirectUnlessSignedIn();

    $scope.backToIndex = function() {
      $location.path('/admin/payPeriods/');
    };

    this.init($scope, $location);
    this.fetch($scope, $rootScope, $location, $routeParams, AdminPayPeriod);
  }

  AdminPayPeriodsCtrl.prototype.init = function($scope, $location) {
    // Setting mode based on the url
    $scope.mode = 'show';
    if (/\/pay-periods$/.test($location.path())) return $scope.mode = 'index';
    if (/\/new$/.test($location.path())) return $scope.mode = 'new';
    if (/\/edit$/.test($location.path())) return $scope.mode = 'edit';
  };

  AdminPayPeriodsCtrl.prototype.fetch = function($scope, $rootScope, $location, $routeParams, AdminPayPeriod) {
    if ($scope.mode === 'index') {
      AdminPayPeriod.list().then(function(items) {
        $scope.payPeriods = items.entities;

        // Breadcrumbs: Pay Periods
        $rootScope.breadcrumbs.push({title: 'Pay Periods'});

      });

    } else if ($scope.mode === 'new') {

    } else if ($scope.mode === 'show') {
      AdminPayPeriod.get($routeParams.payPeriodId).then(function(item) {
        $scope.payPeriod = item.properties;

        // Breadcrumbs: Pay Periods / Pay Period ID
        $rootScope.breadcrumbs.push({title: 'Pay Periods', href: '/admin/pay-periods'});
        $rootScope.breadcrumbs.push({title: $scope.payPeriod.id});

      });

    } else if ($scope.mode === 'edit') {
      AdminPayPeriod.get($routeParams.payPeriodId).then(function(item) {
        $scope.payPeriod = item.properties;

        // Breadcrumbs: Pay Periods / Pay Period ID / Update Pay Period
        $rootScope.breadcrumbs.push({title: 'Pay Periods', href: '/admin/pay-periods'});
        $rootScope.breadcrumbs.push({title: $scope.payPeriod.id, href: '/admin/pay-periods/' + $scope.payPeriod.id});
        $rootScope.breadcrumbs.push({title: 'Update Pay Period'});

      });
    }
  };

  AdminPayPeriodsCtrl.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$anchorScroll', '$http', 'AdminPayPeriod'];
  angular.module('powurApp').controller('AdminPayPeriodsCtrl', AdminPayPeriodsCtrl);

})();
