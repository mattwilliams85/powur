;(function() {
  'use strict';

  function AdminProductReceiptsCtrl($scope, $rootScope, $location, $routeParams, $http, $anchorScroll, CommonService) {
    $scope.redirectUnlessSignedIn();

    $scope.templateData = {
      index: {
        title: 'Product Receipts',
        tablePath: 'admin/product-receipts/templates/table.html'
      }
    };

    $scope.pagination = function(direction) {
      var page = 1,
          sort;
      if ($scope.index.data) {
        page = $scope.index.data.properties.paging.current_page;
        sort = $scope.index.data.properties.sorting.current_sort;
      }
      page += direction;
      return CommonService.execute({
        href: '/a/product_receipts',
        params: {
          page: page,
          sort: sort
        }
      }).then(function(data) {
        $scope.index.data = data;
        $anchorScroll();
      });
    };

    $scope.confirm = function(msg, clickAction, arg) {
      if (window.confirm(msg)) {
        return $scope.$eval(clickAction)(arg);
      }
    };

    $scope.markAsRefunded = function(item) {
      var action = getAction(item.actions, 'refund');

      $http({
        method: action.method,
        url: action.href,
      }).success(function(data) {
        item.properties = data.properties;
        $scope.showModal('This purchase has been marked as refunded');
      });
    };

    this.init($scope, $location);
    this.fetch($scope, $rootScope, $location, $routeParams, CommonService);
  }

  AdminProductReceiptsCtrl.prototype.init = function($scope, $location){
    // Set mode based on URL
    $scope.mode = 'show';
    if (/\/product_receipts$/.test($location.path())) return $scope.mode = 'index';
  };

  AdminProductReceiptsCtrl.prototype.fetch = function($scope, $rootScope, $location, $routeParams, CommonService) {
    if ($scope.mode === 'index') {
      $rootScope.breadcrumbs.push({title: 'Product Receipts'});
      $scope.index = {};
      $scope.pagination(0);
    }
  };

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

  AdminProductReceiptsCtrl.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$http', '$anchorScroll', 'CommonService'];
  angular.module('powurApp').controller('AdminProductReceiptsCtrl', AdminProductReceiptsCtrl);
})();
