'use strict';

function ProfileCtrl($scope, UserProfile) {
  $scope.redirectUnlessSignedIn();
}

ProfileCtrl.$inject = ['$scope', 'UserProfile'];
sunstandControllers.controller('ProfileCtrl', ProfileCtrl);
