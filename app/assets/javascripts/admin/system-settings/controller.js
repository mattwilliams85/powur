;(function() {
  'use strict';

  function AdminSystemSettingsCtrl($scope, $rootScope, $location, $routeParams, $http) {
    $scope.redirectUnlessSignedIn();

    $scope.templateData = {
      index: {
        title: 'Settings',
        tablePath: 'admin/system-settings/templates/table.html'
      },
      edit: {
        title: 'Update Setting',
        formPath: 'admin/system-settings/templates/form.html'
      }
    };

    $scope.update = function() {
      var action;
      if ($scope.systemSetting) {
        $scope.isSubmitDisabled = true;
        action = getAction($scope.actions, 'update');
        $http({
          method: action.method,
          url: action.href,
          data: { value: $scope.systemSetting.value }
        }).success(function(data) {
          $scope.isSubmitDisabled = false;
          if (data.error) {
            $scope.showModal('Oops error, saving data');
          } else {
            $location.path('/admin/system-settings');
            $scope.showModal('You\'ve successfully updated this setting.');
          }
        }).error(function() {
          $scope.isSubmitDisabled = false;
        });
      }
    };

    $scope.cancel = function() {
      $location.path('/admin/system-settings');
    };

    this.init($scope, $location);
    this.fetch($scope, $rootScope, $routeParams, $http);
  }

  AdminSystemSettingsCtrl.prototype.init = function($scope, $location) {
    $scope.mode = 'index';
    if (/\/edit$/.test($location.path())) return $scope.mode = 'edit';
  };

  AdminSystemSettingsCtrl.prototype.fetch = function($scope, $rootScope, $routeParams, $http) {
    if ($scope.mode === 'index') {
      $rootScope.breadcrumbs.push({title: 'Settings'});
      $scope.index = {};
      $http({
        method: 'GET',
        url: '/a/system_settings'
      }).success(function(data) {
        $scope.index.data = data;
      });
    } else if ($scope.mode === 'edit') {
      $http({
        method: 'GET',
        url: '/a/system_settings/' + $routeParams.settingId
      }).success(function(data) {
        $scope.systemSetting = data.properties;
        $scope.actions = data.actions;
        $rootScope.breadcrumbs.push({title: 'Settings', href:'/admin/system-settings'});
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

  AdminSystemSettingsCtrl.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$http'];
  angular.module('powurApp').controller('AdminSystemSettingsCtrl', AdminSystemSettingsCtrl);
})();
