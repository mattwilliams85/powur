'use strict';

function UserStaticContentCtrl($scope) {
  $scope.redirectUnlessSignedIn();

  UserProfile.get().then(function(user) {
    $scope.currentUser = user;
  });
}

UserStaticContentCtrl.$inject = ['$scope'];
sunstandControllers.controller('UserStaticContentCtrl', UserStaticContentCtrl);
