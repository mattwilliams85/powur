;(function() {
  'use strict';

  function AdminProductsCtrl($scope, $rootScope, $location, $routeParams, $http, $anchorScroll, CommonService) {
    $scope.redirectUnlessSignedIn();

    $scope.templateData = {
      index: {
        title: 'Products',
        // links: [
        //   {href: '/admin/products/new', text: 'Add'}
        // ],
        tablePath: 'admin/products/templates/table.html'
      },
      new: {
        title: 'Add a Product',
        formPath: 'admin/products/templates/form.html'
      },
      edit: {
        title: 'Update a Product',
        formPath: 'admin/products/templates/form.html'
      }
    };

    $scope.pagination = function(direction) {
      var page = 1;
      if ($scope.indexData) {
        page = $scope.indexData.properties.paging.current_page;
      }
      page += direction;
      return CommonService.execute({
        href: '/a/products.json?page=' + page
      }).then(function(data) {
        $scope.indexData = data;
        $anchorScroll();
      });
    };

    // Create Product Action
    $scope.create = function() {
      if ($scope.product) {
        // dollars to cents
        $scope.product.bonus_volume *= 100;

        $scope.isSubmitDisabled = true;
        CommonService.execute($scope.formAction, $scope.product).then(function success(data) {
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

        CommonService.execute($scope.formAction, $scope.product).then(function success(data) {
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
        return CommonService.execute(action).then(function() {
          $scope.showModal(productName + ' has been removed from the system.');
          $location.path('/admin/products');
        }, function() {
          $scope.showModal('There was an error deleting this product.');
        });
      }
    };

    $scope.cancel = function() {
      $location.path('/admin/products');
    };

    this.init($scope, $location);
    this.fetch($scope, $rootScope, $location, $routeParams, CommonService);
  }

  AdminProductsCtrl.prototype.init = function($scope, $location){
    // Set mode based on URL
    $scope.mode = 'show';
    if (/\/products$/.test($location.path())) return $scope.mode = 'index';
    if (/\/new$/.test($location.path())) return $scope.mode = 'new';
    if (/\/edit$/.test($location.path())) return $scope.mode = 'edit';
  };

  AdminProductsCtrl.prototype.fetch = function($scope, $rootScope, $location, $routeParams, CommonService) {
    if ($scope.mode === 'index') {
      $rootScope.breadcrumbs.push({title: 'Products'});
      $scope.pagination(0);
    } else if ($scope.mode === 'new') {
      CommonService.execute({
        href: '/a/products.json'
      }).then(function(items) {
        $scope.product = {};
        $scope.formAction = getAction(items.actions, 'create');
        // Breadcrumbs: Products
        $rootScope.breadcrumbs.push({title: 'Products', href: '/admin/products'});
        $rootScope.breadcrumbs.push({title: 'New Product'});
      });
    } else if ($scope.mode === 'edit') {
      CommonService.execute({
        href: '/a/products/' + $routeParams.productId + '.json'
      }).then(function(item) {
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

  AdminProductsCtrl.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$http', '$anchorScroll', 'CommonService'];
  angular.module('powurApp').controller('AdminProductsCtrl', AdminProductsCtrl);
})();
