;(function() {
  'use strict';

  function AdminLatestNewsCtrl($scope, $rootScope, $location, $routeParams, $anchorScroll, $http, CommonService) {
    $scope.redirectUnlessSignedIn();

    $scope.cancel = function() {
      $location.path('/admin/latest-news');
    };

    $scope.confirm = function(msg, clickAction, arg) {
      if (window.confirm(msg)) {
        return $scope.$eval(clickAction)(arg);
      }
    };

    $scope.delete = function(item) {
      var action = getAction(item.actions, 'delete');
      return CommonService.execute(action).then(function() {
        $scope.showModal('This resource has been deleted.');
        $location.path('/admin/latest-news');
        $scope.currentPage = 0;
        $scope.items = [];
        $scope.loadMore();
      }, function() {
        $scope.showModal('Oops, error while deleting');
      });
    };

    $scope.formattedTime = function(timestamp) {
      var date = new Date(timestamp);
      var day = (date.getDate() < 10 ? '0' : '') + date.getDate();
      var month = ((date.getMonth() + 1) < 10 ? '0' : '') + (date.getMonth() + 1);
      var year = date.getFullYear();
      var time = date.toTimeString().replace(/.*(\d{2}:\d{2}:\d{2}).*/, '$1');
      return month + '/' + day + '/' + year + ' ' + time;
    };

    $scope.loadMore = function() {
      var nextPage = $scope.currentPage + 1;

      CommonService.execute({
        href: '/a/notifications.json?page=' + nextPage
      }).then(function(items) {
        for (var i in items.entities) {
          $scope.items.push(items.entities[i]);
        }
        $scope.currentPage = items.properties.paging.current_page;
        $scope.morePages = (items.properties.paging.page_count >= $scope.currentPage) ? true : false;
      });
    };

    $scope.create = function() {
      if ($scope.latestNewsItem) {
        $scope.isSubmitDisabled = true;
        // User Autolinker.js to turn links into hyperlinks
        $scope.latestNewsItem.content = Autolinker.link($scope.latestNewsItem.content);
        CommonService.execute($scope.formAction, $scope.latestNewsItem).then(actionCallback($scope.formAction));
      }
    };

    $scope.update = function() {
      if ($scope.latestNewsItem) {
        $scope.isSubmitDisabled = true;
        // User Autolinker.js to turn links into hyperlinks
        $scope.latestNewsItem.content = Autolinker.link($scope.latestNewsItem.content);
        CommonService.execute($scope.formAction, $scope.latestNewsItem).then(actionCallback($scope.formAction));
      }
    };

    $scope.execute = function (action, notification) {
      if (action.name === 'update') {
        $scope.latestNewsItem = notification;
        $location.path('/admin/latest-news/' + $scope.latestNewsItem.properties.id + '/edit');
      } else if (action.name === 'delete') {
        if (window.confirm('Are you sure you want to delete this Latest News item?')) {
          CommonService.execute(action, notification).then(actionCallback(action));
        }
      } else {
        CommonService.execute(action, notification).then(actionCallback(action));
      }
    };

    function actionCallback(action) {
      var destination = '/admin/latest-news',
          modalMessage = '';
      if (action.name === 'create') {
        modalMessage = ('You\'ve successfully added a new item.');
        $scope.isSubmitDisabled = false;
      } else if (action.name === 'update') {
        modalMessage = ('You\'ve successfully updated this item.');
      } else if (action.name === 'delete') {
        modalMessage = ('You\'ve successfully deleted this item.');
      }

      return CommonService.execute({
        href: '/a/notifications.json'
      }).then(function(items) {
        $location.path(destination);
        $scope.items = items.entities;
        $scope.currentPage = items.properties.paging.current_page;
        $scope.morePages = (items.properties.paging.page_count >= $scope.currentPage) ? true : false;
        $scope.showModal(modalMessage);
      });
    }

    this.init($scope, $location);
    this.fetch($scope, $rootScope, $location, $routeParams, CommonService);
  }

  AdminLatestNewsCtrl.prototype.init = function($scope, $location) {
    // Setting mode based on the url
    $scope.mode = 'index';
    if (/\/latest-news$/.test($location.path())) return $scope.mode = 'index';
    if (/\/new$/.test($location.path())) return $scope.mode = 'new';
    if (/\/edit$/.test($location.path())) return $scope.mode = 'edit';
  };

  AdminLatestNewsCtrl.prototype.fetch = function($scope, $rootScope, $location, $routeParams, CommonService) {
    if ($scope.mode === 'index') {
      CommonService.execute({
        href: '/a/notifications.json'
      }).then(function(items) {
        $scope.items = items.entities;
        $scope.currentPage = items.properties.paging.current_page;
        $scope.morePages = (items.properties.paging.page_count >= $scope.currentPage) ? true : false;

        // Breadcrumbs: Latest News
        $rootScope.breadcrumbs.push({title: 'Latest News'});
      });

    } else if ($scope.mode === 'new') {
      CommonService.execute({
        href: '/a/notifications.json'
      }).then(function(items) {
        $scope.formAction = getAction(items.actions, 'create');
        $scope.latestNewsItem = {};
      });

      // Breadcrumbs: Latest News / View Item
      $rootScope.breadcrumbs.push({title: 'Latest News', href: '/admin/latest-news'});
      $rootScope.breadcrumbs.push({title: 'New Item'});

    } else if ($scope.mode === 'edit') {
      CommonService.execute({
        href: '/a/notifications/' + $routeParams.notificationId + '.json'
      }).then(function(item) {
        $scope.latestNewsItem = item.properties;
        $scope.formAction = getAction(item.actions, 'update');

        // Breadcrumbs: Latest News / Update Item
        $rootScope.breadcrumbs.push({title: 'Latest News', href: '/admin/latest-news'});
        $rootScope.breadcrumbs.push({title: 'Update Item'});
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

  AdminLatestNewsCtrl.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$anchorScroll', '$http', 'CommonService'];
  angular.module('powurApp').controller('AdminLatestNewsCtrl', AdminLatestNewsCtrl);
})();
