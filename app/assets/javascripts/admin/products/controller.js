;(function() {
  'use strict';

  function AdminProductsCtrl($scope, $rootScope, $location, $routeParams, $http, AdminProduct) {
    $scope.redirectUnlessSignedIn();

    // Utility Functions
    $scope.getAction = function (actions, name) {
      for (var i in actions) {
        if (actions[i].name === name) {
          return actions[i];
        }
      }
      return;
    };

    $scope.cancel = function() {
      $location.path('/admin/products');
    };

    // Create Product Action
    $scope.create = function() {
      if ($scope.product) {
        $scope.isSubmitDisabled = true;
        AdminProduct.execute($scope.formAction, $scope.product).then(actionCallback($scope.formAction));
      }
    };

    // Update Product Action
    $scope.update = function() {
      if ($scope.product) {
        AdminProduct.execute($scope.formAction, $scope.product).then(actionCallback($scope.formAction));
      }
    }

    // Delete Product Action
    $scope.delete = function(productObj) {
      var action = $scope.getAction(productObj.actions, 'delete');
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

    function actionCallback(action) {
      var destination = '/admin/products/' + $scope.product.id,
          modalMessage = '';

      // update action needs to send user back to product show page
      if (action.name === 'update') {
        destination = ('/admin/products/' + $scope.product.id);
        modalMessage = ('You\'ve successfully updated this product.');
        return AdminProduct.get($routeParams.productId).then(function(item) {
          $location.path(destination);
          $scope.product = item.properties;
          $scope.showModal(modalMessage);
        });

      // create and delete actions need to send user back to products list page
      } else if (action.name === 'create') {
        destination = ('/admin/products');
        modalMessage = ('You\'ve successfully added a new product.');
        $scope.isSubmitDisabled = false;
      } else if (action.name === 'delete') {
        destination = ('/admin/products');
        modalMessage = ('You\'ve successfully deleted this product.');
      }
      return AdminProduct.list().then(function(items) {
        $location.path(destination);
        $scope.products = items.entities;
        $scope.showModal(modalMessage);
      });

    }

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
        $scope.products = items.entities;

        // Breadcrumbs: Products
        $rootScope.breadcrumbs.push({title: 'Products'});
      });
    } else if ($scope.mode === 'new') {
      AdminProduct.list().then(function(items) {
        $scope.product = {};
        $scope.formAction = $scope.getAction(items.actions, 'create');

        // Breadcrumbs: Products
        $rootScope.breadcrumbs.push({title: 'Products', href: '/admin/products'});
        $rootScope.breadcrumbs.push({title: 'New Product'});
      });
    } else if ($scope.mode === 'show') {
      AdminProduct.get($routeParams.productId).then(function(item) {
        $scope.product = item.properties;

        // Breadcrumbs: Products / Product Name
        $rootScope.breadcrumbs.push({title: 'Products', href: '/admin/products'});
        $rootScope.breadcrumbs.push({title: $scope.product.name});
      });
    } else if ($scope.mode === 'edit') {
      AdminProduct.get($routeParams.productId).then(function(item) {
        $scope.product = item.properties;
        $scope.productObj = item;
        $scope.formAction = $scope.getAction($scope.productObj.actions, 'update');

        var fields = $scope.formAction.fields;
        // Holy Loop to fill form with existing values 🙌
        for (var i in fields) {
          $scope.product[fields[i].name] = fields[i].value;
        }

        // Breadcrumbs: Products / Product Name
        $rootScope.breadcrumbs.push({title: 'Products', href: '/admin/products'});
        $rootScope.breadcrumbs.push({title: $scope.product.name, href: '/admin/products/' + $scope.product.id});
        $rootScope.breadcrumbs.push({title: 'Update Product'});

      });
    }
  };

  AdminProductsCtrl.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$http', 'AdminProduct'];
  angular.module('powurApp').controller('AdminProductsCtrl', AdminProductsCtrl);
})();