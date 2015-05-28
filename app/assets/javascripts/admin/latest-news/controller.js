;(function() {
  'use strict';

  function AdminLatestNewsCtrl($scope, $rootScope, $location, $routeParams, $anchorScroll, $http, CommonService) {
    $scope.redirectUnlessSignedIn();

    $scope.templateData = {
      index: {
        title: 'Latest News',
        links: [
          {href: '/admin/latest-news/new', text: 'Add'}
        ],
        tablePath: 'admin/latest-news/templates/table.html'
      },
      new: {
        title: 'Add a News Item',
        formPath: 'admin/latest-news/templates/form.html'
      },
      edit: {
        title: 'Update a News Item',
        formPath: 'admin/latest-news/templates/form.html'
      }
    };

    // Form Validation
    $scope.formErrorMessages = {};

    $scope.delete = function(item) {
      var action = getAction(item.actions, 'delete');
      return CommonService.execute(action).then(function() {
        $scope.showModal('This item has been deleted.');
        $location.path('/admin/latest-news');
        $scope.pagination(0);
      }, function() {
        $scope.showModal('Oops, error while deleting');
      });
    };

    $scope.pagination = function(direction) {
      var page = 1;
      if ($scope.data) {
        page = $scope.data.properties.paging.current_page;
      }
      page += direction;
      return CommonService.execute({
        href: '/a/notifications.json?page=' + page
      }).then(function(data) {
        $scope.data = data;
        $anchorScroll();
      });
    };

    function formErrorCallback(data) {
      $scope.isSubmitDisabled = false;
      $scope.formErrorMessages = {};
      var keys = ['content'];
      for(var i in keys) {
        var errorMessage = data.errors[keys[i]];
        if (errorMessage) {
          $scope.formErrorMessages[keys[i]] = errorMessage[0];
        }
      }
    }

    $scope.create = function() {
      if ($scope.item) {
        $scope.isSubmitDisabled = true;
        // User Autolinker.js to turn links into hyperlinks
        $scope.item.content = Autolinker.link($scope.item.content);
        CommonService.execute($scope.formAction, $scope.item).then(function success() {
          $scope.isSubmitDisabled = false;
          $location.path('/admin/latest-news');
          $scope.showModal('Data successfully saved');
        }, formErrorCallback);
      }
    };

    $scope.update = function() {
      if ($scope.item) {
        $scope.isSubmitDisabled = true;
        // User Autolinker.js to turn links into hyperlinks
        $scope.item.content = Autolinker.link($scope.item.content);
        CommonService.execute($scope.formAction, $scope.item).then(function success() {
          $scope.isSubmitDisabled = false;
          $location.path('/admin/latest-news');
          $scope.showModal('Data successfully saved');
        }, formErrorCallback);
      }
    };

    $scope.formattedTime = function(timestamp) {
      var date = new Date(timestamp);
      var day = (date.getDate() < 10 ? '0' : '') + date.getDate();
      var month = ((date.getMonth() + 1) < 10 ? '0' : '') + (date.getMonth() + 1);
      var year = date.getFullYear();
      var time = date.toTimeString().replace(/.*(\d{2}:\d{2}:\d{2}).*/, '$1');
      return month + '/' + day + '/' + year + ' ' + time;
    };

    $scope.cancel = function() {
      $location.path('/admin/latest-news');
    };

    $scope.confirm = function(msg, clickAction, arg) {
      if (window.confirm(msg)) {
        return $scope.$eval(clickAction)(arg);
      }
    };

    this.init($scope, $location);
    this.fetch($scope, $rootScope, $location, $routeParams, CommonService);
  }

  AdminLatestNewsCtrl.prototype.init = function($scope, $location) {
    // Setting mode based on the url
    $scope.mode = 'index';
    if (/\/new$/.test($location.path())) return $scope.mode = 'new';
    if (/\/edit$/.test($location.path())) return $scope.mode = 'edit';
  };

  AdminLatestNewsCtrl.prototype.fetch = function($scope, $rootScope, $location, $routeParams, CommonService) {
    if ($scope.mode === 'index') {
      $rootScope.breadcrumbs.push({title: 'Latest News'});
      $scope.pagination(0);
    } else if ($scope.mode === 'new') {
      CommonService.execute({
        href: '/a/notifications.json'
      }).then(function(items) {
        $scope.formAction = getAction(items.actions, 'create');
        $scope.item = {};
      });

      // Breadcrumbs: Latest News / View Item
      $rootScope.breadcrumbs.push({title: 'Latest News', href: '/admin/latest-news'});
      $rootScope.breadcrumbs.push({title: 'New Item'});

    } else if ($scope.mode === 'edit') {
      CommonService.execute({
        href: '/a/notifications/' + $routeParams.notificationId + '.json'
      }).then(function(item) {
        $scope.item = item.properties;
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
