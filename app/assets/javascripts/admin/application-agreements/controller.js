;(function() {
  'use strict';

  function AdminApplicationAgreementsCtrl($scope, $rootScope, $location, $routeParams, $http, $anchorScroll, CommonService) {
    $scope.redirectUnlessSignedIn();

    $scope.templateData = {
      index: {
        title: 'Application Agreements',
        links: [
          {
            href: '/admin/application-agreements/new',
            text: 'Add'
          }
        ],
        tablePath: 'admin/application-agreements/templates/table.html'
      },
      new: {
        title: 'Add Application Agreement',
        formPath: 'admin/application-agreements/templates/form.html'
      }
    };

    $scope.pagination = function(direction) {
      var page = 1;
      if ($scope.data) {
        page = $scope.data.properties.paging.current_page;
      }
      page += direction;
      return CommonService.execute({
        href: '/a/application_agreements.json?page=' + page
      }).then(function(data) {
        $scope.data = data;
        $anchorScroll();
      });
    };

    $scope.create = function() {
      $scope.formErrorMessages = {};
      $scope.errorMessage = {};
      if ($scope.item) {
        $scope.isSubmitDisabled = true;
        CommonService.execute($scope.formAction, $scope.item).then(function success(data) {
          $scope.isSubmitDisabled = false;
          if (data.error) {
            $scope.errorMessage[data.error.input] = data.error.message;
            return;
          }
          $location.path('/admin/application-agreements');
          $scope.showModal('You\'ve successfully added a new Application Agreement.');
        });
      }
    };

    $scope.publish = function(item) {
      var action = getAction(item.actions, 'publish');
      CommonService.execute(action, $scope.item).then(function success(data) {
        $scope.isSubmitDisabled = false;
        if (data.error) {
          $scope.showModal('Error: This Application Agreement couldn\'t be published.');
          return;
        }
        item.properties = data.properties;
        $scope.showModal('You\'ve successfully published a new Application Agreement.');
      });
    };

    $scope.unpublish = function(item) {
      var action = getAction(item.actions, 'unpublish');
      CommonService.execute(action, $scope.item).then(function success(data) {
        $scope.isSubmitDisabled = false;
        if (data.error) {
          $scope.showModal('Error: This Application Agreement couldn\'t be unpublished.');
          return;
        }
        item.properties = data.properties;
        $scope.showModal('You\'ve successfully un-published this Application Agreement.');
      });
    };

    $scope.delete = function(item) {
      var action = getAction(item.actions, 'delete');
      if (window.confirm('Are you sure you want to delete this item?')) {
        return CommonService.execute(action).then(function() {
          $scope.showModal('Item has been removed from the system.');
          $location.path('/admin/application-agreements');
        }, function() {
          $scope.showModal('There was an error deleting this item.');
        });
      }
    };

    $scope.cancel = function() {
      $location.path('/admin/application-agreements');
    };

    this.init($scope, $location);
    this.fetch($scope, $rootScope, $location, $routeParams, CommonService);
  }

  AdminApplicationAgreementsCtrl.prototype.init = function($scope, $location){
    // Set mode based on URL
    $scope.mode = 'index';
    if (/\/new$/.test($location.path())) return $scope.mode = 'new';
  };

  AdminApplicationAgreementsCtrl.prototype.fetch = function($scope, $rootScope, $location, $routeParams, CommonService) {
    if ($scope.mode === 'index') {
      $rootScope.breadcrumbs.push({title: 'Application Agreements'});
      $scope.pagination(0);
    } else if ($scope.mode === 'new') {
      CommonService.execute({
        href: '/a/application_agreements.json'
      }).then(function(items) {
        $scope.item = {};
        $scope.formAction = getAction(items.actions, 'create');
        // Breadcrumbs: Products
        $rootScope.breadcrumbs.push({title: 'Application Agreements', href: '/admin/application-agreements'});
        $rootScope.breadcrumbs.push({title: 'New Application Agreement'});
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

  AdminApplicationAgreementsCtrl.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$http', '$anchorScroll', 'CommonService'];
  angular.module('powurApp').controller('AdminApplicationAgreementsCtrl', AdminApplicationAgreementsCtrl);
})();
