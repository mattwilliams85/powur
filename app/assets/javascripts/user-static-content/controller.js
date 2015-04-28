'use strict';

function UserStaticContentCtrl($scope, UserProfile) {
  $scope.redirectUnlessSignedIn();

  UserProfile.get().then(function(user) {
    $scope.currentUser = user;
  });
}

UserStaticContentCtrl.$inject = ['$scope', 'UserProfile'];
sunstandControllers.controller('UserStaticContentCtrl', UserStaticContentCtrl);
