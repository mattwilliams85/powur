;(function() {
  'use strict';

  function AdminSocialMediaCtrl($scope, $rootScope, $location, $routeParams, $anchorScroll, $http, AdminSocialMedia) {
    $scope.redirectUnlessSignedIn();

    $scope.backToIndex = function() {
      $location.path('/admin/social-media/');
    };

    this.init($scope, $location);
    this.fetch($scope, $rootScope, $location, $routeParams, AdminSocialMedia);
  }

  AdminSocialMediaCtrl.prototype.init = function($scope, $location) {
    // Setting mode based on the url
    $scope.mode = 'show';
    if (/\/social-media$/.test($location.path())) return $scope.mode = 'index';
    if (/\/new$/.test($location.path())) return $scope.mode = 'new';
    if (/\/edit$/.test($location.path())) return $scope.mode = 'edit';
  };

  AdminSocialMediaCtrl.prototype.fetch = function($scope, $rootScope, $location, $routeParams, AdminSocialMedia) {
    if ($scope.mode === 'index') {
      AdminSocialMedia.list().then(function(items) {
        $scope.socialMedia = items.entities;

        // Breadcrumbs: Social Media Sharing
        $rootScope.breadcrumbs.push({title: 'Social Media Sharing'});

      });

    } else if ($scope.mode === 'new') {

    } else if ($scope.mode === 'show') {
      AdminSocialMedia.get($routeParams.socialMediaPostId).then(function(item) {
        $scope.socialMediaPost = item.properties;

        // Breadcrumbs: Social Media Sharing / View Post
        $rootScope.breadcrumbs.push({title: 'Social Media Sharing', href: '/admin/social-media'});
        $rootScope.breadcrumbs.push({title: 'View Post'});

      });

    } else if ($scope.mode === 'edit') {
      AdminSocialMedia.get($routeParams.socialMediaPostId).then(function(item) {
        $scope.socialMediaPost = item.properties;

        // Breadcrumbs: Social Media Sharing / Update Post
        $rootScope.breadcrumbs.push({title: 'Social Media Sharing', href: '/admin/social-media'});
        $rootScope.breadcrumbs.push({title: 'Update Post'});

      });
    }
  };

  AdminSocialMediaCtrl.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$anchorScroll', '$http', 'AdminSocialMedia'];
  angular.module('powurApp').controller('AdminSocialMediaCtrl', AdminSocialMediaCtrl);

})();
