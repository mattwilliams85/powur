;(function() {
  'use strict';

  function AdminResourcesCtrl($scope, $rootScope, $location, $routeParams, $anchorScroll, AdminResource) {
    $scope.redirectUnlessSignedIn();

    // TODO check if user is an admin
    // (backend validation is in place, this is just usability optimization)

    // Form Validation
    $scope.formErrorMessages = {};
    $scope.itemsPaging = {
      current_page: 1
    };

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

    $scope.itemThumbnail = function(item) {
      var imgPath = item.properties.image_original_path;
      if (imgPath) return imgPath;
      return item.properties.file_type === 'video/mp4' ? legacyImagePaths.libraryResources[0] : legacyImagePaths.libraryResources[1];
    };

    $scope.delete = function(item) {
      var action = getAction(item.actions, 'destroy');
      return AdminResource.execute(action).then(function() {
        $scope.showModal('This resource has been deleted.');
        $location.path('/resources');
        $scope.pagination(0);
      }, function() {
        $scope.showModal('Oops error deleting the resource');
      });
    };

    $scope.cancel = function() {
      $location.path('/resources');
    };

    $scope.errorMessage = function(name) {
      return $scope.formErrorMessages[name];
    };

    var createCallback = function() {
      $location.path('/resources');
      $scope.showModal('You\'ve successfully added a ' + $scope.resourceType + ' to the library.');
      $scope.isSubmitDisabled = false;
    };

    var createErrorCallback = function(data) {
      $scope.formErrorMessages = {};
      if (data.errors['file_type']) data.errors['file_original_path'] = data.errors['file_type'];
      var keys = ['title', 'description', 'file_original_path'];
      for(var i in keys) {
        var errorMessage = data.errors[keys[i]];
        if (errorMessage) {
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
      $location.path('/resources');
      $scope.showModal('You\'ve successfully updated this ' + $scope.resourceType + '.');
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

    $scope.pagination = function(direction) {
      var page = $scope.itemsPaging.current_page + direction;
      return AdminResource.list({page: page, search: $scope.searchText}).then(function(items) {
        $scope.resources = items.entities;
        $scope.itemsPaging = items.properties.paging;
        $anchorScroll();
      });
    };

    $scope.search = function() {
      $scope.itemsPaging = {
        current_page: 1
      };
      $scope.pagination(0);
    };

    this.init($scope, $location);
    this.fetch($scope, $rootScope, $location, $routeParams, AdminResource);
  }

  AdminResourcesCtrl.prototype.init = function($scope, $location) {
    // Setting mode based on the url
    $scope.mode = 'index';
    if (/\/new\//.test($location.path())) return $scope.mode = 'new';
    if (/\/edit$/.test($location.path())) return $scope.mode = 'edit';
  };

  AdminResourcesCtrl.prototype.fetch = function($scope, $rootScope, $location, $routeParams, AdminResource) {
    if ($scope.mode === 'index') {
      $scope.pagination(0);
      // Breadcrumbs: Library
      $rootScope.breadcrumbs.push({title: 'Library'});
    } else if ($scope.mode === 'new') {
      $scope.resourceType = $routeParams.resourceType === 'video' ? 'video' : 'document';
      $scope.resource = {
        is_public: true
      };
      // Breadcrumbs: Library / New (Resource Type)
      $rootScope.breadcrumbs.push({title: 'Library', href:'/admin/resources'});
      $rootScope.breadcrumbs.push({title: 'New ' + $scope.resourceType});
    } else if ($scope.mode === 'edit') {
      AdminResource.get($routeParams.resourceId).then(function(item) {
        $scope.resource = item.properties;
        $scope.resourceType = $scope.resource.file_type === 'video/mp4' ? 'video' : 'document';
        // Breadcrumbs: Library / Update (Resource Type)
        $rootScope.breadcrumbs.push({title: 'Library', href:'/admin/resources'});
        $rootScope.breadcrumbs.push({title: 'Update ' + $scope.resourceType});
      });

    }
  };


  AdminResourcesCtrl.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$anchorScroll', 'AdminResource'];
  angular.module('powurApp').controller('AdminResourcesCtrl', AdminResourcesCtrl);

})();