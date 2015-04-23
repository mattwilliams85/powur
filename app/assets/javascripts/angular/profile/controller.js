'use strict';

function ProfileCtrl($scope, UserProfile) {
  $scope.redirectUnlessSignedIn();

  UserProfile.get().then(function(user) {
    $scope.currentUser = user;
    $scope.userProfile = user;
  });

  $scope.updateProfile = function() {
    if ($scope.userProfile) {
      UserProfile.update({user: $scope.userProfile}).then(function() {
        $scope.showModal('Personal information successfully updated');
      });
    }
  };

  $scope.updatePassword = function() {
    if ($scope.password) {
      UserProfile.updatePassword($scope.password).then(function(data) {
        if (data.error) {
          $scope.showModal(data.error.message);
        } else {
          $scope.showModal('Password successfully updated');
          $scope.password = {};
        }
      });
    }
  };
}

ProfileCtrl.$inject = ['$scope', 'UserProfile'];
sunstandControllers.controller('ProfileCtrl', ProfileCtrl);
