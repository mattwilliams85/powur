;(function() {
  'use strict';

  function AdminOrdersCtrl($scope, $rootScope, $location, $routeParams, Order) {
    $scope.redirectUnlessSignedIn();

    $scope.backToIndex = function() {
      $location.path('/admin/orders/');
    };

    this.init($scope, $location);
    this.fetch($scope, $rootScope, $location, $routeParams, Order);
  }

  AdminOrdersCtrl.prototype.init = function($scope, $location) {
    // Setting mode based on the url
    $scope.mode = 'show';
    if (/\/orders$/.test($location.path())) return $scope.mode = 'index';
    if (/\/new$/.test($location.path())) return $scope.mode = 'new';
    if (/\/edit$/.test($location.path())) return $scope.mode = 'edit';
  };

  AdminOrdersCtrl.prototype.fetch = function($scope, $rootScope, $location, $routeParams, Order) {
    if ($scope.mode === 'index') {
      Order.list().then(function(items) {
        $scope.orders = items.entities;

        // Breadcrumbs: Orders
        $rootScope.breadcrumbs.push({title: 'Orders'});
      });
    } else if ($scope.mode === 'new') {

    } else if ($scope.mode === 'show') {
      Order.get($routeParams.userId).then(function(item) {
        $scope.user = item.properties;

        // Breadcrumbs: Orders / View Order
        $rootScope.breadcrumbs.push({title: 'Orders', href: '/admin/orders'});
        $rootScope.breadcrumbs.push({title: 'View Order'});
      });
    } else if ($scope.mode === 'edit') {
      Order.get($routeParams.userId).then(function(item) {
        $scope.user = item.properties;

        // Breadcrumbs: Orders / Update Order
        $rootScope.breadcrumbs.push({title: 'Orders', href: '/admin/orders'});
        $rootScope.breadcrumbs.push({title: 'Update Order'});
      });
    }
  };

  AdminOrdersCtrl.$inject = ['$scope', '$rootScope', '$location', '$routeParams', 'Order'];
  angular.module('powurApp').controller('AdminOrdersCtrl', AdminOrdersCtrl);

})();
