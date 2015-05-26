;(function() {
  'use strict';

  function AdminProductsCtrl($scope, $rootScope, $location, $routeParams, $http, AdminProduct) {
    $scope.redirectUnlessSignedIn();

    $scope.cancel = function() {
      $location.path('/admin/products');
    };

    // Create Product Action
    $scope.create = function() {
      if ($scope.product) {
        // dollars to cents
        $scope.product.bonus_volume *= 100;

        $scope.isSubmitDisabled = true;
        AdminProduct.execute($scope.formAction, $scope.product).then(function success(data) {
          $scope.isSubmitDisabled = false;
          if (data.error) {
            $scope.product.bonus_volume /= 100;
            $scope.showModal('Error, while saving data, please check input');
            return;
          }
          $location.path('/admin/products');
          $scope.showModal('You\'ve successfully added a new product.');
        });
      }
    };

    // Update Product Action
    $scope.update = function() {
      if ($scope.product) {
        // dollars to cents
        $scope.product.bonus_volume *= 100;

        AdminProduct.execute($scope.formAction, $scope.product).then(function success(data) {
          $scope.isSubmitDisabled = false;
          if (data.error) {
            $scope.product.bonus_volume /= 100;
            $scope.showModal('Error, while saving data, please check input');
            return;
          }
          $location.path('/admin/products');
          $scope.showModal('You\'ve successfully updated this product.');
        });
      }
    };

    // Delete Product Action
    $scope.delete = function(productObj) {
      var action = getAction(productObj.actions, 'delete');
      var productName = productObj.properties.name;
      if (window.confirm('Are you sure you want to delete ' + productName + '?')) {
        return AdminProduct.execute(action).then(function() {
          $scope.showModal(productName + ' has been removed from the system.');
          $location.path('/admin/products');
        }, function() {
          $scope.showModal('There was an error deleting this product.');
        });
      }
    };

    this.init($scope, $location);
    this.fetch($scope, $rootScope, $location, $routeParams, AdminProduct);
  }

  AdminProductsCtrl.prototype.init = function($scope, $location){
    // Set mode based on URL
    $scope.mode = 'show';
    if (/\/products$/.test($location.path())) return $scope.mode = 'index';
    if (/\/new$/.test($location.path())) return $scope.mode = 'new';
    if (/\/edit$/.test($location.path())) return $scope.mode = 'edit';
  };

  AdminProductsCtrl.prototype.fetch = function($scope, $rootScope, $location, $routeParams, AdminProduct) {
    if ($scope.mode === 'index') {
      AdminProduct.list().then(function(items) {
        $scope.items = items.entities;
        $rootScope.breadcrumbs.push({title: 'Products'});
      });
    } else if ($scope.mode === 'new') {
      AdminProduct.list().then(function(items) {
        $scope.product = {};
        $scope.formAction = getAction(items.actions, 'create');
        // Breadcrumbs: Products
        $rootScope.breadcrumbs.push({title: 'Products', href: '/admin/products'});
        $rootScope.breadcrumbs.push({title: 'New Product'});
      });
    } else if ($scope.mode === 'edit') {
      AdminProduct.get($routeParams.productId).then(function(item) {
        // Cents to dollars
        var bonusVolumeField = getField(getAction(item.actions, 'update').fields, 'bonus_volume');
        bonusVolumeField.value /= 100;
        $scope.product = item.properties;
        $scope.productObj = item;
        $scope.formAction = getAction($scope.productObj.actions, 'update');
        var fields = $scope.formAction.fields;
        // Holy Loop to fill form with existing values 🙌
        for (var i in fields) {
          $scope.product[fields[i].name] = fields[i].value;
        }
        $rootScope.breadcrumbs.push({title: 'Products', href: '/admin/products'});
        $rootScope.breadcrumbs.push({title: 'Update Product'});
      });
    }
  };

  // Utility Functions
  function getAction(actions, name) {
    for (var i in actions) {
      if (actions[i].name === name) {
        return actions[i];
      }
    }
    return;
  }

  function getField(fields, name) {
    for (var i in fields) {
      if (fields[i].name === name) {
        return fields[i];
      }
    }
    return;
  }

  AdminProductsCtrl.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$http', 'AdminProduct'];
  angular.module('powurApp').controller('AdminProductsCtrl', AdminProductsCtrl);
})();
