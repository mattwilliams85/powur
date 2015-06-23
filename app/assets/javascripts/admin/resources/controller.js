;(function() {
  'use strict';

  function AdminResourcesCtrl($scope, $rootScope, $location, $routeParams, $anchorScroll, CommonService) {
    $scope.redirectUnlessSignedIn();

    $scope.templateData = {
      index: {
        title: 'Library',
        links: [
          {href: '/admin/resources/new/video', text: 'Add Video'},
          {href: '/admin/resources/new/document', text: 'Add PDF'}
        ],
        tablePath: 'admin/resources/templates/table.html'
      },
      new: {
        title: 'Add a Library Resource',
        formPath: 'admin/resources/templates/form.html'
      },
      edit: {
        title: 'Update a Library Resource',
        formPath: 'admin/resources/templates/form.html'
      }
    };

    $scope.legacyImagePaths = legacyImagePaths;

    // TODO check if user is an admin
    // (backend validation is in place, this is just usability optimization)

    // Form Validation
    $scope.formErrorMessages = {};

    $scope.delete = function(item) {
      var action = getAction(item.actions, 'destroy');
      return CommonService.execute(action).then(function() {
        $scope.showModal('This item has been deleted.');
        $location.path('/admin/resources');
        $scope.pagination(0);
      }, function() {
        $scope.showModal('Oops error deleting the item');
      });
    };

    function formErrorCallback(data) {
      $scope.isSubmitDisabled = false;
      $scope.formErrorMessages = {};
      if (data.errors.file_type) data.errors.file_original_path = data.errors.file_type;
      var keys = ['title', 'description', 'file_original_path'];
      for(var i in keys) {
        var errorMessage = data.errors[keys[i]];
        if (errorMessage) {
          $scope.formErrorMessages[keys[i]] = errorMessage[0];
        }
      }
    }

    $scope.create = function() {
      if ($scope.resource) {
        $scope.isSubmitDisabled = true;
        $scope.resource.youtube_id = validateYoutubeId($scope.resource.youtube_id);
        CommonService.execute({
          method: 'POST',
          href: '/a/resources.json'
        }, $scope.resource).then(function success() {
          $scope.isSubmitDisabled = false;
          $location.path('/admin/resources');
          $scope.showModal('You\'ve successfully added a new resource.');
        }, formErrorCallback);
      }
    };

    $scope.update = function() {
      if ($scope.resource) {
        $scope.isSubmitDisabled = true;
        $scope.resource.youtube_id = validateYoutubeId($scope.resource.youtube_id);
        CommonService.execute({
          method: 'PUT',
          href: '/a/resources/' + $scope.resource.id + '.json'
        }, $scope.resource).then(function success() {
          $scope.isSubmitDisabled = false;
          $location.path('/admin/resources');
          $scope.showModal('You\'ve successfully updated this resource');
        }, formErrorCallback);
      }
    };

    $scope.pagination = function(direction) {
      var page = 1;
      if ($scope.data) {
        page = $scope.data.properties.paging.current_page;
      }
      page += direction;
      return CommonService.execute({
        href: '/a/resources.json?page=' + page
      }).then(function(data) {
        $scope.data = data;
        $anchorScroll();
      });
    };

    $scope.search = function() {
      $scope.pagination(0);
    };

    $scope.cancel = function() {
      $location.path('/admin/resources');
    };

    $scope.errorMessage = function(name) {
      return $scope.formErrorMessages[name];
    };

    $scope.itemThumbnail = function(item) {
      var imgPath = item.properties.image_original_path;
      if (imgPath) {
        return imgPath;
      } else if (item.properties.youtube_id) {
        return 'http://img.youtube.com/vi/' + item.properties.youtube_id + '/hqdefault.jpg';
      }
      return item.properties.file_type === 'video/mp4' ? legacyImagePaths.libraryResources[0] : legacyImagePaths.libraryResources[1];
    };

    $scope.confirm = function(msg, clickAction, arg) {
      if (window.confirm(msg)) {
        return $scope.$eval(clickAction)(arg);
      }
    };

    function validateYoutubeId(youtubeId) {
      if (!youtubeId || typeof youtubeId === 'undefined') return;

      var re, str;

      // Test for regular full youtube url
      re = /v\=(.+)$/i;
      str = youtubeId.match(re);
      if (str && str.length) return str[1];

      // Test for embed youtube url
      re = /be\/(.+)$/i;
      str = youtubeId.match(re);
      if (str && str.length) return str[1];

      return youtubeId;
    }

    this.init($scope, $location);
    this.fetch($scope, $rootScope, $location, $routeParams, CommonService);
  }

  AdminResourcesCtrl.prototype.init = function($scope, $location) {
    // Setting mode based on the url
    $scope.mode = 'index';
    if (/\/new\//.test($location.path())) return $scope.mode = 'new';
    if (/\/edit$/.test($location.path())) return $scope.mode = 'edit';
  };

  AdminResourcesCtrl.prototype.fetch = function($scope, $rootScope, $location, $routeParams, CommonService) {
    if ($scope.mode === 'index') {
      // Breadcrumbs: Library
      $rootScope.breadcrumbs.push({title: 'Library'});
      $scope.pagination(0);
    } else if ($scope.mode === 'new') {
      // Breadcrumbs: Library / New (Resource Type)
      $scope.resourceType = $routeParams.resourceType === 'video' ? 'video' : 'document';
      $rootScope.breadcrumbs.push({title: 'Library', href:'/admin/resources'});
      $rootScope.breadcrumbs.push({title: 'New ' + $scope.resourceType});
      $scope.resource = {
        is_public: true
      };
      getTopics();
    } else if ($scope.mode === 'edit') {
      CommonService.execute({
        href: '/a/resources/' + $routeParams.resourceId + '.json'
      }).then(function(item) {
        // Breadcrumbs: Library / Update (Resource Type)
        $scope.resource = item.properties;
        $scope.resourceType = item.properties.file_type === 'video/mp4' ? 'video' : 'document';
        getTopics();
        $rootScope.breadcrumbs.push({title: 'Library', href:'/admin/resources'});
        $rootScope.breadcrumbs.push({title: 'Update ' + $scope.resourceType});
      });
    }

    function getTopics() {
      CommonService.execute({
        href: '/a/resource_topics.json'
      }).then(function(data) {
        $scope.topics = data.entities;
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

  AdminResourcesCtrl.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$anchorScroll', 'CommonService'];
  angular.module('powurApp').controller('AdminResourcesCtrl', AdminResourcesCtrl);
})();
