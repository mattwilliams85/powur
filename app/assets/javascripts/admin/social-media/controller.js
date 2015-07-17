;(function() {
  'use strict';

  function AdminSocialMediaCtrl($scope, $rootScope, $location, $routeParams, $anchorScroll, $http, CommonService) {
    $scope.redirectUnlessSignedIn();


    $scope.templateData = {
      index: {
        title: 'Social Media Sharing',
        links: [
          {href: '/admin/social-media/new', text: 'New Post'}
        ],
        tablePath: 'admin/social-media/templates/table.html'
      },
      new: {
        title: 'New Social Media Post',
        formPath: 'admin/social-media/templates/form.html'
      },
      edit: {
        title: 'Edit Social Media Post',
        formPath: 'admin/social-media/templates/form.html'
      }
    };

    $scope.pagination = function(direction) {
      var page = 1,
          sort;
      if ($scope.index.data) {
        page = $scope.index.data.properties.paging.current_page;
        sort = $scope.index.data.properties.sorting.current_sort;
      }
      page += direction;
      return CommonService.execute({
        href: '/a/social_media_posts',
        params: {
          page: page,
          sort: sort
        }
      }).then(function(data) {
        $scope.index.data = data;
        $anchorScroll();
      });
    };

    $scope.cancel = function() {
      $location.path('/admin/social-media');
    };

    $scope.create = function() {
      if ($scope.socialMediaPost) {
        $scope.isSubmitDisabled = true;
        CommonService.execute($scope.formAction, $scope.socialMediaPost).then(function success(data) {
          if (data.error) {
            $scope.showModal('There was an error while saving this post.' + '<br>' + data.error.message);
            $scope.isSubmitDisabled = false;
            return;
          }
          $location.path('admin/social-media')
          $scope.showModal('You\'ve successfully added a new social media post!');
        });
      }
    };

    $scope.update = function() {
      if ($scope.socialMediaPost) {
        CommonService.execute($scope.formAction, $scope.socialMediaPost).then(function success(data) {
          $scope.isSubmitDisabled = true;
          if (data.error) {
            $scope.showModal('There was an error while updating this post.' + '<br>' + data.error.message);
            return;
          }
          $location.path('/admin/social-media');
          $scope.showModal('You\'ve successfully updated this social media post!');
        })
      }
    }

    $scope.delete = function(socialMediaPostObj) {
      var deleteAction = getAction(socialMediaPostObj.actions, 'delete');
      if (window.confirm('Are you sure you want to delete this post?')) {
        return CommonService.execute(deleteAction).then(function() {
          $scope.showModal('This social media post has been deleted.');
          $location.path('/admin/social-media');
        }, function() {
          $scope.showModal('There was an error deleting this post.');
        });
      }
    }

    this.init($scope, $location);
    this.fetch($scope, $rootScope, $location, $routeParams, CommonService);
  }

  // Utility Functions
  function getAction(actions, name) {
    for (var i in actions) {
      if (actions[i].name === name) {
        return actions[i];
      }
    }
    return;
  }

  AdminSocialMediaCtrl.prototype.init = function($scope, $location) {
    // Setting mode based on the url
    $scope.mode = 'show';
    if (/\/social-media$/.test($location.path())) return $scope.mode = 'index';
    if (/\/new$/.test($location.path())) return $scope.mode = 'new';
    if (/\/edit$/.test($location.path())) return $scope.mode = 'edit';
  };

  AdminSocialMediaCtrl.prototype.fetch = function($scope, $rootScope, $location, $routeParams, CommonService) {
    if ($scope.mode === 'index') {
      // Breadcrumbs: Social Media Sharing
      $rootScope.breadcrumbs.push({title: 'Social Media Sharing'});
      $scope.index = {};
      $scope.pagination(0);
    } else if ($scope.mode === 'new') {
      // Breadcrumbs: Social Media Sharing / New Social Media Post
      $rootScope.breadcrumbs.push({title: 'Social Media Sharing', href: '/admin/social-media'});
      $rootScope.breadcrumbs.push({title: 'New Social Media Post'});

      CommonService.execute({
        href: '/a/social_media_posts.json'
      }).then(function(items) {
        $scope.socialMediaPost = {};
        $scope.formAction = getAction(items.actions, 'create');
      });

    } else if ($scope.mode === 'edit') {
      // Breadcrumbs: Social Media Sharing / Edit Social Media Post
      $rootScope.breadcrumbs.push({title: 'Social Media Sharing', href: '/admin/social-media'});
      $rootScope.breadcrumbs.push({title: 'Edit Social Media Post'});

      CommonService.execute({
        href: '/a/social_media_posts/' + $routeParams.socialMediaPostId + '.json'
      }).then(function(item) {
        $scope.socialMediaPost = item.properties;
        $scope.socialMediaPostObj = item;
        $scope.formAction = getAction(item.actions, 'update');
      });
    }
  };

  AdminSocialMediaCtrl.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$anchorScroll', '$http', 'CommonService'];
  angular.module('powurApp').controller('AdminSocialMediaCtrl', AdminSocialMediaCtrl);

})();
