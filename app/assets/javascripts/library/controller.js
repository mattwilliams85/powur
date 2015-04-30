;(function() {
  'use strict';

  function LibraryCtrl($scope, $location, Resource, UserProfile) {
    $scope.redirectUnlessSignedIn();

    UserProfile.get().then(function(user) {
      $scope.currentUser = user;
      if (user.require_enrollment) {
        $location.path('/university');
        $scope.showModal($scope.enrollmentRequirementMessage);
        return;
      }
    });

    $scope.items = [];
    $scope.itemsPaging = {
      current_page: 1
    };
    $scope.resourceTypes = [{name: 'All Media'}, {name: 'Videos', type: 'videos'}, {name: 'Documents', type: 'documents'}];
    $scope.resourceType = $scope.resourceTypes[0];

    $scope.showResource = function(item) {
      // adding source on click to avoid preloading all videos on init page show
      if (item.properties.file_type === 'video/mp4') {
        $('#item_' + item.properties.id + ' video').html('<source src="' + item.properties.file_original_path + '" type="video/mp4">');
      }
      var html = $('#item_' + item.properties.id).html();
      $('<div class=\'reveal-modal library-modal\' data-reveal>' + html + '<a class=\'close-reveal-modal\'>&#215;</a></div>').foundation('reveal', 'open');
    };

    $scope.resourceTypeChange = function() {
      return Resource.list({type: $scope.resourceType.type }).then(function(items) {
        $scope.items = items.entities;
        $scope.pages = items.properties.paging;
      });
    };

    $scope.itemThumbnail = function(item) {
      var imgPath = item.properties.image_original_path;
      if (imgPath) return imgPath;
      return item.properties.file_type === 'video/mp4' ? legacyImagePaths.libraryResources[0] : legacyImagePaths.libraryResources[1];
    };

    $scope.search = function() {
      $scope.itemsPaging = {
        current_page: 1
      };
      $scope.items = [];
      $scope.pagination(0);
    };

    $scope.pagination = function(direction) {
      var page = $scope.itemsPaging.current_page + direction;
      return Resource.list({page: page, search: $scope.searchText}).then(function(items) {
        $scope.items = $scope.items.concat(items.entities);
        $scope.pages = items.properties.paging;
      });
    };

    return Resource.list().then(function(items) {
      $scope.items = items.entities;
      $scope.pages = items.properties.paging;
    });
  }

  LibraryCtrl.$inject = ['$scope', '$location', 'Resource', 'UserProfile'];
  angular.module('powurApp').controller('LibraryCtrl', LibraryCtrl);
})();
