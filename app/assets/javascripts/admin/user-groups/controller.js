;(function() {
  'use strict';

  function AdminUserGroupsCtrl($scope, $rootScope, $location, $routeParams, $anchorScroll, $http, AdminUserGroup) {
    $scope.redirectUnlessSignedIn();
    $scope.view = 'overview';
    $scope.userGroup = {};
    $scope.formErrorMessages = {};
    // TODO check if user is an admin

    // Utility Functions
    function getAction(actions, name) {
      for (var i in actions) {
        if (actions[i].name === name) {
          return actions[i];
        }
      }
      return;
    }

    $scope.cancel = function() {
      $location.path('/user-groups');
    };

    // Create Action & Related Callbacks
    $scope.create = function() {
      if ($scope.userGroup) {
        $scope.isSubmitDisabled = true;
        AdminUserGroup.create($scope.userGroup).then(createCallback, createErrorCallback);
      }
    };

    var createCallback = function() {
      $location.path('/user-groups');
      $scope.showModal('You\'ve successfully added a new user group.');
      $scope.isSubmitDisabled = false;
    };

    var createErrorCallback = function(data) {
      $scope.formErrorMessages = {};
      var keys = ['id', 'title'];
      for(var i in keys) {
        $scope.userGroupForm[keys[i]].$dirty = false;
        var errorMessage = data.errors[keys[i]];
        if (errorMessage) {
          $scope.userGroupForm[keys[i]].$dirty = true;
          $scope.formErrorMessages[keys[i]] = errorMessage[0];
        }
      }
      $scope.isSubmitDisabled = false;
    };

    // Update Action & Related Callbacks
    $scope.update = function() {
      if ($scope.userGroup) {
        $scope.isSubmitDisabled = true;
        AdminUserGroup.update($scope.userGroup).then(updateCallback);
      }
    };

    var updateCallback = function() {
      $location.path('/user-groups/' + $scope.userGroup.id);
      $scope.showModal('You\'ve successfully updated this user group.');
      $scope.isSubmitDisabled = false;
    };

    // Delete Action
    $scope.delete = function(userGroupObj) {
      var action = getAction(userGroupObj.actions, 'delete');
      var groupName = userGroupObj.properties.title;
      if (window.confirm("Are you sure you want to delete the ‘" + groupName + "’ user group?")) {
        return AdminUserGroup.execute(action).then(function() {
          $scope.showModal("The ‘" + groupName + "’ user group has been deleted.");
          $location.path('/user-groups');
        }, function() {
          $scope.showModal('There was an error deleting this user group.');
        });
      }
    };

    // List Actions
    $scope.getUsersFromGroup = function (groupId) {
      $http({
        method: 'GET',
        url: '/a/users.json?group=' + groupId
      }).success(function(res) {
        $scope.users = res.entities;
      }).error(function(err) {
        console.log('エラー', err);
      });
    };

    this.init($scope, $location);
    this.fetch($scope, $rootScope, $location, $routeParams, AdminUserGroup);
  }


  AdminUserGroupsCtrl.prototype.init = function($scope, $location) {
    // Setting mode based on the url

    $scope.mode = 'show';

    if (/\/user-groups$/.test($location.path())) return $scope.mode = 'index';
    if (/\/new$/.test($location.path())) return $scope.mode = 'new';
    if (/\/edit$/.test($location.path())) return $scope.mode = 'edit';
  };


  AdminUserGroupsCtrl.prototype.fetch = function($scope, $rootScope, $location, $routeParams, AdminUserGroup) {
    if ($scope.mode === 'index') {
      AdminUserGroup.list().then(function(items) {
        $scope.userGroups = items.entities;

        // Breadcrumbs: User Groups
        $rootScope.breadcrumbs.push({title: 'User Groups'});

      });

    } else if ($scope.mode === 'new') {
      $scope.disableIdEdit = false;

      // Breadcrumbs: User Groups / New User Group
      $rootScope.breadcrumbs.push({title: 'User Groups', href: '/admin/user-groups'});
      $rootScope.breadcrumbs.push({title: 'New User Group'});

    } else if ($scope.mode === 'show') {
      AdminUserGroup.get($routeParams.userGroupId).then(function(item) {
        $scope.userGroup = item.properties;

        // get users from /a/users endpoint
        $scope.users = [];
        $scope.getUsersFromGroup(item.properties.id);
        // get requirements
        $scope.requirements = item.entities[1].entities;
        // get bonuses
        $scope.bonuses = [];

        // Breadcrumbs: User Groups / User Group Name
        $rootScope.breadcrumbs.push({title: 'User Groups', href: '/admin/user-groups'});
        $rootScope.breadcrumbs.push({title: $scope.userGroup.title});

      });

    } else if ($scope.mode === 'edit') {
      AdminUserGroup.get($routeParams.userGroupId).then(function(item) {
        $scope.userGroup = item.properties;
        $scope.userGroupObj = item;
        $scope.group = item;
        $scope.disableIdEdit = true;

        // Breadcrumbs: User Groups / User Group Name / Update User Group
        $rootScope.breadcrumbs.push({title: 'User Groups', href: '/admin/user-groups'});
        $rootScope.breadcrumbs.push({title: $scope.userGroup.title, href: '/admin/user-groups/' + $scope.userGroup.id});
        $rootScope.breadcrumbs.push({title: 'Update User Group'});

      });
    }
  };


  AdminUserGroupsCtrl.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$anchorScroll', '$http', 'AdminUserGroup'];
  angular.module('powurApp').controller('AdminUserGroupsCtrl', AdminUserGroupsCtrl);

})();
