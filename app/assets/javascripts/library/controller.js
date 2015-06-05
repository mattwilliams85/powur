;(function() {
  'use strict';

  function LibraryCtrl($scope, $rootScope, $location, CommonService, UserProfile) {
    $scope.redirectUnlessSignedIn();

    UserProfile.get().then(function(user) {
      $rootScope.currentUser = user;
    });

    $scope.videoIconImagePath = legacyImagePaths.videoIconImagePath;

    $scope.items = [];
    $scope.itemsPaging = {
      current_page: 1
    };
    $scope.resourceTypes = [{name: 'All Media'}, {name: 'Videos', type: 'videos'}, {name: 'Documents', type: 'documents'}];
    $scope.resourceType = $scope.resourceTypes[0];

    $scope.showResource = function(item) {
      // adding source on click to avoid preloading all videos on init page show
      if (item.properties.file_type === 'video/mp4') {
        $('#item_' + item.properties.id + ' video').hide();
        $('#item_' + item.properties.id + ' iframe').remove();

        if (item.properties.file_original_path) {
          $('#item_' + item.properties.id + ' video').html('<source src=\'' + item.properties.file_original_path + '\' type=\'video/mp4\'>').show();
        } else if (item.properties.youtube_id) {
          $('#item_' + item.properties.id + ' .video-content-wrapper').prepend('<iframe type=\'text/html\' width=\'100%\' height=\'380px\' src=\'https://www.youtube.com/embed/' + item.properties.youtube_id + '\' frameborder=\'0\' modestbranding=\'1\' autohide=\'1\' showinfo=\'1\' controls=\'1\';></iframe>');
        }
      }
      var html = $('#item_' + item.properties.id).html();
      $('<div class=\'reveal-modal library-modal\' data-reveal>' + html + '<a class=\'close-reveal-modal\'>&#215;</a></div>').foundation('reveal', 'open');
    };

    $scope.resourceTypeChange = function() {
      return CommonService.execute({
        href: '/u/resources.json?type=' + $scope.resourceType.type
      }).then(function(items) {
        $scope.items = items.entities;
        $scope.pages = items.properties.paging;
      });
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

    $scope.search = function() {
      $scope.itemsPaging = {
        current_page: 1
      };
      $scope.items = [];
      $scope.pagination(0);
    };

    $scope.pagination = function(direction) {
      var page = $scope.itemsPaging.current_page + direction;
      return CommonService.execute({
        href: '/u/resources.json?page=' + page + '&search=' + $scope.searchText
      }).then(function(items) {
        $scope.items = $scope.items.concat(items.entities);
        $scope.pages = items.properties.paging;
      });
    };

    return CommonService.execute({
      href: '/u/resources.json'
    }).then(function(items) {
      $scope.items = items.entities;
      $scope.pages = items.properties.paging;
    });
  }

  LibraryCtrl.$inject = ['$scope', '$rootScope', '$location', 'CommonService', 'UserProfile'];
  angular.module('powurApp').controller('LibraryCtrl', LibraryCtrl);
})();
