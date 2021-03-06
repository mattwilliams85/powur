;(function() {
  'use strict';

  function AdminUserGroupBonusesCtrl($scope, $rootScope, $location, $routeParams, $anchorScroll, $http, AdminUserGroup) {
    $scope.redirectUnlessSignedIn();
    $scope.view = 'bonuses';
    $scope.userGroup = {};
    // TODO check if user is an admin

    $scope.cancel = function() {
      $location.path('/admin/user-groups/'+ $scope.userGroup.id + '/bonuses');
    };

    return AdminUserGroup.get($routeParams.userGroupId).then(function(item) {
      $scope.userGroup = item.properties;
      $scope.bonuses = [];

      // Breadcrumbs: User Groups / User Group Name / Bonuses
      $rootScope.breadcrumbs.push({title: 'User Groups', href: '/admin/user-groups'});
      $rootScope.breadcrumbs.push({title: $scope.userGroup.title, href: '/admin/user-groups/' + $scope.userGroup.id});
      $rootScope.breadcrumbs.push({title: 'Bonuses'});
    });
  }

  AdminUserGroupBonusesCtrl.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$anchorScroll', '$http', 'AdminUserGroup'];
  angular.module('powurApp').controller('AdminUserGroupBonusesCtrl', AdminUserGroupBonusesCtrl);
})();
