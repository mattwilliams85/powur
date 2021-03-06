;(function() {
  'use strict';

  function AdminUserGroupUsersCtrl($scope, $rootScope, $location, $routeParams, $anchorScroll, $http, AdminUserGroup) {
    $scope.redirectUnlessSignedIn();
    $scope.view = 'users';
    $scope.userGroup = {};
    // TODO check if user is an admin

    $scope.cancel = function() {
      $location.path('/admin/user-groups/');
    };

    $scope.panel = 'overview';
    $scope.showPanel = function(panelName) {
      if ($scope.panel === panelName) return true;
      return false;
    };

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

    return AdminUserGroup.get($routeParams.userGroupId).then(function(item) {
      $scope.userGroup = item.properties;
      $scope.getUsersFromGroup($scope.userGroup.id);

      // Breadcrumbs: User Groups / User Group Name / Users
      $rootScope.breadcrumbs.push({title: 'User Groups', href: '/admin/user-groups'});
      $rootScope.breadcrumbs.push({title: $scope.userGroup.title, href: '/admin/user-groups/' + $scope.userGroup.id});
      $rootScope.breadcrumbs.push({title: 'Users'});

    });
  }


  AdminUserGroupUsersCtrl.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$anchorScroll', '$http', 'AdminUserGroup'];
  angular.module('powurApp').controller('AdminUserGroupUsersCtrl', AdminUserGroupUsersCtrl);

})();
