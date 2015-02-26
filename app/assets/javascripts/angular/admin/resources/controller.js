'use strict';

function AdminResourcesCtrl($scope, $location, $routeParams, AdminResource) {
  $scope.redirectUnlessSignedIn();

  // TODO check if user is an admin

  $scope.formattedTime = function(timestamp) {
    var date = new Date(timestamp);
    var day = (date.getDate() < 10 ? '0' : '') + date.getDate();
    var month = ((date.getMonth() + 1) < 10 ? '0' : '') + (date.getMonth() + 1);
    var year = date.getFullYear();
    var time = date.toTimeString().replace(/.*(\d{2}:\d{2}:\d{2}).*/, '$1');
    return month + '/' + day + '/' + year + ' ' + time;
  };

  $scope.publish = function(item) {

  };

  $scope.unPublish = function(item) {

  };

  $scope.delete = function(item) {

  };

  this.init($scope, $location);
  this.fetch($scope, $location, $routeParams, AdminResource);
}


AdminResourcesCtrl.prototype.init = function($scope, $location) {
  // Setting mode based on the url
  $scope.mode = 'index';
  if (/\/new$/.test($location.path())) return $scope.mode = 'new';
  if (/\/edit$/.test($location.path())) return $scope.mode = 'edit';
};


AdminResourcesCtrl.prototype.fetch = function($scope, $location, $routeParams, AdminResource) {
  if ($scope.mode === 'index') {
    return AdminResource.list().then(function(items) {
      $scope.resources = items.entities;
    });
  } else if ($scope.mode === 'new') {

  } else if ($scope.mode === 'edit') {

  }
};


AdminResourcesCtrl.$inject = ['$scope', '$location', '$routeParams', 'AdminResource'];
sunstandControllers.controller('AdminResourcesCtrl', AdminResourcesCtrl);
