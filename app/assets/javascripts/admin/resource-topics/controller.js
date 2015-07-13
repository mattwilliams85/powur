;(function() {
  'use strict';

  function AdminResourceTopicsCtrl($scope, $rootScope, $location, $routeParams, $anchorScroll, CommonService) {
    $scope.redirectUnlessSignedIn();

    $scope.templateData = {
      index: {
        title: 'Library Topics',
        links: [
          {href: '/admin/resource-topics/new', text: 'Add'},
        ],
        tablePath: 'admin/resource-topics/templates/table.html'
      },
      new: {
        title: 'Add a Library Topic',
        formPath: 'admin/resource-topics/templates/form.html'
      },
      edit: {
        title: 'Update a Library Topic',
        formPath: 'admin/resource-topics/templates/form.html'
      }
    };

    // Form Validation
    $scope.formErrorMessages = {};

    $scope.delete = function(item) {
      var action = getAction(item.actions, 'destroy');
      return CommonService.execute(action).then(function() {
        $scope.showModal('This item has been deleted.');
        $location.path('/admin/resource-topics');
        $scope.pagination(0);
      }, function() {
        $scope.showModal('Oops error deleting the item');
      });
    };

    $scope.create = function() {
      if ($scope.resourceTopic) {
        $scope.isSubmitDisabled = true;
        CommonService.execute({
          method: 'POST',
          href: '/a/resource_topics.json'
        }, $scope.resourceTopic).then(function success(data) {
          $scope.isSubmitDisabled = false;
          if (data.error) {
            $scope.formErrorMessages[data.error.input] = data.error.message;
          } else {
            $location.path('/admin/resource-topics');
            $scope.showModal('You\'ve successfully added a new resource topic.');
          }
        });
      }
    };

    $scope.update = function() {
      if ($scope.resourceTopic) {
        $scope.isSubmitDisabled = true;
        CommonService.execute({
          method: 'PUT',
          href: '/a/resource_topics/' + $scope.resourceTopic.id + '.json'
        }, $scope.resourceTopic).then(function success(data) {
          $scope.isSubmitDisabled = false;
          if (data.error) {
            $scope.formErrorMessages[data.error.input] = data.error.message;
          } else {
            $location.path('/admin/resource-topics');
            $scope.showModal('You\'ve successfully updated this resource topic.');
          }
        });
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
        href: '/a/resource_topics',
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
      $location.path('/admin/resource-topics');
    };

    $scope.errorMessage = function(name) {
      return $scope.formErrorMessages[name];
    };

    $scope.confirm = function(msg, clickAction, arg) {
      if (window.confirm(msg)) {
        return $scope.$eval(clickAction)(arg);
      }
    };

    this.init($scope, $location);
    this.fetch($scope, $rootScope, $location, $routeParams, CommonService);
  }

  AdminResourceTopicsCtrl.prototype.init = function($scope, $location) {
    $scope.mode = 'index';
    if (/\/new/.test($location.path())) return $scope.mode = 'new';
    if (/\/edit$/.test($location.path())) return $scope.mode = 'edit';
  };

  AdminResourceTopicsCtrl.prototype.fetch = function($scope, $rootScope, $location, $routeParams, CommonService) {
    if ($scope.mode === 'index') {
      $rootScope.breadcrumbs.push({title: 'Library Topics'});
      $scope.index = {};
      $scope.pagination(0);
    } else if ($scope.mode === 'new') {
      $rootScope.breadcrumbs.push({title: 'Library Topics', href:'/admin/resource-topics'});
      $rootScope.breadcrumbs.push({title: 'New'});
      $scope.resourceTopic = {};
    } else if ($scope.mode === 'edit') {
      CommonService.execute({
        href: '/a/resource_topics/' + $routeParams.topicId + '.json'
      }).then(function(item) {
        $scope.resourceTopic = item.properties;
        $rootScope.breadcrumbs.push({title: 'Library', href:'/admin/resource-topics'});
        $rootScope.breadcrumbs.push({title: 'Update'});
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

  AdminResourceTopicsCtrl.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$anchorScroll', 'CommonService'];
  angular.module('powurApp').controller('AdminResourceTopicsCtrl', AdminResourceTopicsCtrl);
})();
