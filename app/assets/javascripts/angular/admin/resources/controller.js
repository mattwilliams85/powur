'use strict';

function AdminResourcesCtrl($scope, $location, $routeParams, AdminResource) {
  $scope.redirectUnlessSignedIn();

  // TODO check if user is an admin

  // Form Validation
  $scope.formErrorMessages = {};

  function getAction(actions, name) {
    for (var i in actions) {
      if (actions[i].name === name) {
        return actions[i];
      }
    }
    return;
  }

  $scope.formattedTime = function(timestamp) {
    var date = new Date(timestamp);
    var day = (date.getDate() < 10 ? '0' : '') + date.getDate();
    var month = ((date.getMonth() + 1) < 10 ? '0' : '') + (date.getMonth() + 1);
    var year = date.getFullYear();
    var time = date.toTimeString().replace(/.*(\d{2}:\d{2}:\d{2}).*/, '$1');
    return month + '/' + day + '/' + year + ' ' + time;
  };

  $scope.delete = function(item) {
    var action = getAction(item.actions, 'destroy');
    return AdminResource.execute(action).then(function() {
      $scope.showModal('Resource has been deleted');
      $(document).foundation();
      $location.path('/admin/resources/');
    }, function() {
      $scope.showModal('Oops error deleting the resource');
      $(document).foundation();
    });
  };

  $scope.cancel = function() {
    $location.path('/admin/resources/');
  };

  $scope.errorMessage = function(name) {
    return $scope.formErrorMessages[name];
  };

  var createCallback = function() {
    $location.path('/admin/resources');
    $scope.showModal('You\'ve successfully added file to a library.');
    $(document).foundation();
    $scope.isSubmitDisabled = false;
  };

  var createErrorCallback = function(data) {
    $scope.formErrorMessages = {};
    var keys = ['title', 'description', 'file_original_path'];
    for(var i in keys) {
      $scope.resourceForm[keys[i]].$dirty = false;
      var errorMessage = data.errors[keys[i]];
      if (errorMessage) {
        $scope.resourceForm[keys[i]].$dirty = true;
        $scope.formErrorMessages[keys[i]] = errorMessage[0];
      }
    }
    $scope.isSubmitDisabled = false;
  };

  $scope.create = function() {
    if ($scope.resource) {
      $scope.isSubmitDisabled = true;
      AdminResource.create($scope.resource).then(createCallback, createErrorCallback);
    }
  };

  var updateCallback = function() {
    $location.path('/admin/resources');
    $scope.showModal('You\'ve successfully updated a library resource.');
    $(document).foundation();
    $scope.isSubmitDisabled = false;
  };

  $scope.update = function() {
    if ($scope.resource) {
      $scope.isSubmitDisabled = true;
      AdminResource.update($scope.resource).then(updateCallback, createErrorCallback);
    }
  };

  $scope.confirm = function(msg, clickAction, arg) {
    if (window.confirm(msg)) {
      return $scope.$eval(clickAction)(arg);
    }
  };

  this.init($scope, $location);
  this.fetch($scope, $location, $routeParams, AdminResource);
}


AdminResourcesCtrl.prototype.init = function($scope, $location) {
  // Setting mode based on the url
  $scope.mode = 'index';
  if (/\/new\//.test($location.path())) return $scope.mode = 'new';
  if (/\/edit$/.test($location.path())) return $scope.mode = 'edit';
};


AdminResourcesCtrl.prototype.fetch = function($scope, $location, $routeParams, AdminResource) {
  if ($scope.mode === 'index') {
    return AdminResource.list().then(function(items) {
      $scope.resources = items.entities;
    });
  } else if ($scope.mode === 'new') {
    $scope.resourceType = $routeParams.resourceType === 'video' ? 'video' : 'document';
    $scope.resource = {
      is_public: true
    };
  } else if ($scope.mode === 'edit') {
    return AdminResource.get($routeParams.resourceId).then(function(item) {
      $scope.resource = item.properties;
      $scope.resourceType = $scope.resource === 'video/mp4' ? 'video' : 'document';
    });
  }
};


AdminResourcesCtrl.$inject = ['$scope', '$location', '$routeParams', 'AdminResource'];
sunstandControllers.controller('AdminResourcesCtrl', AdminResourcesCtrl);
