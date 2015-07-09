;(function() {
  'use strict';

  function AdminNotificationsCtrl($scope, $rootScope, $location, $routeParams, $anchorScroll, $http) {
    $scope.redirectUnlessSignedIn();

    $scope.templateData = {
      index: {
        title: 'Notifications',
        links: [
          { href: '/admin/notifications/new', text: 'Add' },
        ],
        tablePath: 'admin/notifications/templates/table.html'
      },
      new: {
        title: 'Add Notification',
        formPath: 'admin/notifications/templates/form.html'
      },
      edit: {
        title: 'Update Notification',
        formPath: 'admin/notifications/templates/form.html'
      }
    };

    $scope.legacyImagePaths = legacyImagePaths;

    // Form Validation
    $scope.formErrorMessages = {};

    $scope.pagination = function(direction) {
      var page = 1;
      if ($scope.indexData) {
        page = $scope.indexData.properties.paging.current_page;
      }
      page += direction;

      return $http({
        method: 'GET',
        url: '/a/notifications',
        params: { page: page }
      }).success(function(data) {
        $scope.indexData = data;
        $anchorScroll();
      });
    };

    $scope.withNotification = function(id, cb) {
      return $http({
        method: 'GET',
        url: '/a/notifications/' + id
      }).success(cb);
    };

    $scope.create = function() {
      if ($scope.notification) {
        $scope.isSubmitDisabled = true;
        $http({
          method: 'POST',
          url: '/a/notifications',
          data: $scope.notification
        }).success(function() {
          $scope.isSubmitDisabled = false;
          $location.path('/admin/notifications');
          $scope.showModal('Data successfully saved');
        }).error(formErrorCallback);
      }
    };

    $scope.update = function() {
      if ($scope.notification) {
        $scope.isSubmitDisabled = true;
        $http({
          method: $scope.formAction.method,
          url: $scope.formAction.href,
          data: $scope.notification
        }).success(function() {
          $scope.isSubmitDisabled = false;
          $location.path('/admin/notifications');
          $scope.showModal('Data successfully saved');
        }).error(formErrorCallback);
      }
    };

    $scope.delete = function(item) {
      var action = getAction(item.actions, 'delete');
      return $http({
        method: action.method,
        url: action.href
      }).success(function() {
        $scope.showModal('This item has been deleted.');
        $location.path('/admin/notifications');
        $scope.pagination(0);
      }).error(function() {
        $scope.showModal('Oops, error while deleting');
      });
    };

    $scope.cancel = function() {
      $location.path('/admin/notifications');
    };

    $scope.errorMessage = function(name) {
      return $scope.formErrorMessages[name];
    };

    $scope.confirm = function(msg, clickAction, arg) {
      if (window.confirm(msg)) {
        return $scope.$eval(clickAction)(arg);
      }
    };

    function formErrorCallback(data) {
      $scope.isSubmitDisabled = false;
      $scope.formErrorMessages = {};
      var keys = ['content'];
      for(var i in keys) {
        var errorMessage = data.errors[keys[i]];
        if (errorMessage) {
          $scope.formErrorMessages[keys[i]] = errorMessage[0];
        }
      }
    }

    this.init($scope, $location);
    this.fetch($scope, $rootScope, $location, $routeParams);
  }

  AdminNotificationsCtrl.prototype.init = function($scope, $location) {
    $scope.mode = 'index';
    if (/\/new/.test($location.path())) return $scope.mode = 'new';
    if (/\/edit$/.test($location.path())) return $scope.mode = 'edit';
  };

  AdminNotificationsCtrl.prototype.fetch = function($scope, $rootScope, $location, $routeParams) {
    if ($scope.mode === 'index') {
      $rootScope.breadcrumbs.push({title: 'Notifications'});
      $scope.pagination(0);
    } else if ($scope.mode === 'new') {
      $rootScope.breadcrumbs.push({title: 'Notifications', href:'/admin/notifications'});
      $rootScope.breadcrumbs.push({title: 'New notification'});
      $scope.notification = {};
    } else if ($scope.mode === 'edit') {
      $scope.withNotification($routeParams.notificationId, function(item) {
        $scope.notification = item.properties;
        $scope.formAction = getAction(item.actions, 'update');
        $rootScope.breadcrumbs.push({title: 'Notifications', href:'/admin/notifications'});
        $rootScope.breadcrumbs.push({title: 'Update notification'});
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

  AdminNotificationsCtrl.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$anchorScroll', '$http'];
  angular.module('powurApp').controller('AdminNotificationsCtrl', AdminNotificationsCtrl);
})();
