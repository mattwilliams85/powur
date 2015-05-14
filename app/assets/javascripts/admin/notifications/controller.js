;(function() {
  'use strict';

  function AdminNotificationsCtrl($scope, $rootScope, $location, $routeParams, $anchorScroll, $http, CommonService) {
    $scope.redirectUnlessSignedIn();

    // Utility Functions
    $scope.getAction = function (actions, name) {
      for (var i in actions) {
        if (actions[i].name === name) {
          return actions[i];
        }
      }
      return;
    };

    $scope.cancel = function() {
      $location.path('/notifications');
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
      var nextPage = ($scope.currentPage) + 1;

      CommonService.execute({
        href: '/a/notifications.json?page=' + nextPage
      }).then(function(items) {
        for (var i in items.entities) {
          $scope.notifications.push(items.entities[i]);
        }
        $scope.currentPage = items.properties.paging.current_page;
        $scope.morePages = (items.properties.paging.page_count >= $scope.currentPage) ? true : false;
      });
    };

    $scope.create = function() {
      if ($scope.notification) {
        $scope.isSubmitDisabled = true;
        // User Autolinker.js to turn links into hyperlinks
        $scope.notification.content = Autolinker.link($scope.notification.content);
        CommonService.execute($scope.formAction, $scope.notification).then(actionCallback($scope.formAction));
      }
    };

    $scope.update = function() {
      if ($scope.notification) {
        $scope.isSubmitDisabled = true;
        // User Autolinker.js to turn links into hyperlinks
        $scope.notification.content = Autolinker.link($scope.notification.content);
        CommonService.execute($scope.formAction, $scope.notification).then(actionCallback($scope.formAction));
      }
    };

    $scope.execute = function (action, notification) {
      if (action.name === 'update') {
        $scope.notification = notification;
        $location.path('/notifications/' + $scope.notification.properties.id + '/edit');
      } else if (action.name === 'delete') {
        if (window.confirm('Are you sure you want to delete this notification?')) {
          CommonService.execute(action, notification).then(actionCallback(action));
        }
      } else {
        CommonService.execute(action, notification).then(actionCallback(action));
      }
    };

    function actionCallback(action) {
      var destination = '/notifications',
          modalMessage = '';
      if (action.name === 'create') {
        modalMessage = ('You\'ve successfully added a new notification.');
        $scope.isSubmitDisabled = false;
      } else if (action.name === 'update') {
        modalMessage = ('You\'ve successfully updated this notification.');
      } else if (action.name === 'delete') {
        modalMessage = ('You\'ve successfully deleted this notification.');
      }

      return CommonService.execute({
        href: '/a/notifications.json'
      }).then(function(items) {
        $location.path(destination);
        $scope.notifications = items.entities;
        $scope.currentPage = items.properties.paging.current_page;
        $scope.morePages = (items.properties.paging.page_count >= $scope.currentPage) ? true : false;
        $scope.showModal(modalMessage);
      });
    }

    this.init($scope, $location);
    this.fetch($scope, $rootScope, $location, $routeParams, CommonService);
  }

  AdminNotificationsCtrl.prototype.init = function($scope, $location) {
    // Setting mode based on the url
    $scope.mode = 'index';
    if (/\/notifications$/.test($location.path())) return $scope.mode = 'index';
    if (/\/new$/.test($location.path())) return $scope.mode = 'new';
    if (/\/edit$/.test($location.path())) return $scope.mode = 'edit';
  };

  AdminNotificationsCtrl.prototype.fetch = function($scope, $rootScope, $location, $routeParams, CommonService) {
    if ($scope.mode === 'index') {
      CommonService.execute({
        href: '/a/notifications.json'
      }).then(function(items) {
        $scope.notifications = items.entities;
        $scope.currentPage = items.properties.paging.current_page;
        $scope.morePages = (items.properties.paging.page_count >= $scope.currentPage) ? true : false;

        // Breadcrumbs: Notifications
        $rootScope.breadcrumbs.push({title: 'Dashboard Notifications'});
      });

    } else if ($scope.mode === 'new') {
      CommonService.execute({
        href: '/a/notifications.json'
      }).then(function(items) {
        $scope.formAction = $scope.getAction(items.actions, 'create');
        $scope.notification = {};
      });

      // Breadcrumbs: Notifications / View Notification
      $rootScope.breadcrumbs.push({title: 'Dashboard Notifications', href: '/admin/notifications'});
      $rootScope.breadcrumbs.push({title: 'New Notification'});

    } else if ($scope.mode === 'edit') {
      CommonService.execute({
        href: '/a/notifications/' + $routeParams.notificationId + '.json'
      }).then(function(item) {
        $scope.notification = item.properties;
        $scope.formAction = $scope.getAction(item.actions, 'update');

        // Breadcrumbs: Notifications / Update Notification
        $rootScope.breadcrumbs.push({title: 'Dashboard Notifications', href: '/admin/notifications'});
        $rootScope.breadcrumbs.push({title: 'Update Notification'});
      });
    }
  };

  AdminNotificationsCtrl.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$anchorScroll', '$http', 'CommonService'];
  angular.module('powurApp').controller('AdminNotificationsCtrl', AdminNotificationsCtrl);
})();
