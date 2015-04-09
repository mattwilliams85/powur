'use strict';

function AdminNotificationsCtrl($scope, $rootScope, $location, $routeParams, $anchorScroll, $http, AdminNotification) {
  $scope.redirectUnlessSignedIn();

  $scope.backToIndex = function() {
    $location.path('/admin/#/notifications/');
  };

  this.init($scope, $location);
  this.fetch($scope, $rootScope, $location, $routeParams, AdminNotification);
}

AdminNotificationsCtrl.prototype.init = function($scope, $location) {
  // Setting mode based on the url
  $scope.mode = 'show';
  if (/\/notifications$/.test($location.path())) return $scope.mode = 'index';
  if (/\/new$/.test($location.path())) return $scope.mode = 'new';
  if (/\/edit$/.test($location.path())) return $scope.mode = 'edit';
};

AdminNotificationsCtrl.prototype.fetch = function($scope, $rootScope, $location, $routeParams, AdminNotification) {
  if ($scope.mode === 'index') {
    return AdminNotification.list().then(function(items) {
      $scope.notifications = items.entities;
    });
  } else if ($scope.mode === 'new') {

  } else if ($scope.mode === 'show') {
    return AdminNotification.get($routeParams.notificationId).then(function(item) {
      $scope.notification = item.properties;
    });

  } else if ($scope.mode === 'edit') {
    return AdminNotification.get($routeParams.notificationId).then(function(item) {
      $scope.notification = item.properties;
    });
  }
};

AdminNotificationsCtrl.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$anchorScroll', '$http', 'AdminNotification'];
sunstandControllers.controller('AdminNotificationsCtrl', AdminNotificationsCtrl);
