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
  $scope.mode = 'index';
  if (/\/notifications$/.test($location.path())) return $scope.mode = 'index';
  if (/\/new$/.test($location.path())) return $scope.mode = 'new';
  if (/\/edit$/.test($location.path())) return $scope.mode = 'edit';
};

AdminNotificationsCtrl.prototype.fetch = function($scope, $rootScope, $location, $routeParams, AdminNotification) {
  if ($scope.mode === 'index') {
    AdminNotification.list().then(function(items) {
      $scope.notifications = items.entities;

      // Breadcrumbs: Notifications
      $rootScope.breadcrumbs.push({title: 'Notifications'});

    });

  } else if ($scope.mode === 'new') {

    // Breadcrumbs: Notifications / View Notification
    $rootScope.breadcrumbs.push({title: 'Notifications', href: '/admin/#/notifications'});
    $rootScope.breadcrumbs.push({title: 'New Notification'});

  } else if ($scope.mode === 'edit') {
    AdminNotification.get($routeParams.notificationId).then(function(item) {
      $scope.notification = item.properties;

      // Breadcrumbs: Notifications / Update Notification
      $rootScope.breadcrumbs.push({title: 'Notifications', href: '/admin/#/notifications'});
      $rootScope.breadcrumbs.push({title: 'Update Notification'});

    });
  }
};

AdminNotificationsCtrl.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$anchorScroll', '$http', 'AdminNotification'];
sunstandControllers.controller('AdminNotificationsCtrl', AdminNotificationsCtrl);
