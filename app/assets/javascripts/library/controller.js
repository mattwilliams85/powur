;(function() {
  'use strict';

  function LibraryCtrl($scope, $rootScope, $location, CommonService, UserProfile) {
    $scope.redirectUnlessSignedIn();

    UserProfile.get().then(function(user) {
      $rootScope.currentUser = user;
    });

    $scope.legacyImagePaths = legacyImagePaths;

    $scope.resourceTypes = [{name: 'All Media'}, {name: 'Videos', type: 'videos'}, {name: 'Documents', type: 'documents'}];
    $scope.resourceType = $scope.resourceTypes[0];

    $scope.showResource = function(item) {
      item.videoPlayer = null;
      $('#item_' + item.properties.id + ' .reveal-modal').foundation('reveal', 'open');
    };

    $scope.showPlayer = function(item) {
      item.videoPlayer = true;
      if (item.properties.file_original_path) {
        item.videoPlayer = "<video width='100%' controls><source src='" + item.properties.file_original_path + "' type='video/mp4'></video>";
      } else if (item.properties.youtube_id) {
        item.videoPlayer = "<iframe type='text/html' width='100%' src='https://www.youtube.com/embed/" + item.properties.youtube_id + "' frameborder='0' modestbranding='1' autohide='1' showinfo='1' controls='1';></iframe>";
      }
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

    $scope.isVideo = function(item) {
      return item.properties.file_type === 'video/mp4';
    };

    $scope.getResources = function() {
      var href = '/u/resources.json';
      if ($scope.searchText) href += '?search=' + $scope.searchText;
      return CommonService.execute({
        href: href
      }).then(function(items) {
        var topics = items.properties.topics,
            topicId,
            resources = {},
            i;
        // Prepare resources for the UI
        for (i in items.entities) {
          topicId = items.entities[i].properties.topic_id;
          if (!resources[topicId]) resources[topicId] = [];
          resources[topicId].push(items.entities[i]);
        }
        $scope.topics = topics;
        $scope.resources = resources;
      });
    };

    return $scope.getResources();
  }

  LibraryCtrl.$inject = ['$scope', '$rootScope', '$location', 'CommonService', 'UserProfile'];
  angular.module('powurApp').controller('LibraryCtrl', LibraryCtrl);
})();
