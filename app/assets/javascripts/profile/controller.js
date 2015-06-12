;(function() {
  'use strict';

  function ProfileCtrl($scope, $rootScope, UserProfile) {
    $scope.redirectUnlessSignedIn();

    UserProfile.get().then(function(user) {
      $rootScope.currentUser = user;
      $scope.userProfile = user;

      if (user.organic_rank) {
        // Only request ewallet data if the required class complete
        UserProfile.getEwalletDetails().then(function(ewalletDetails) {
          $scope.ewalletDetails = ewalletDetails.properties;
        });
      }
    });

    $scope.legacyImagePaths = legacyImagePaths;

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

    $scope.$watch('userOriginalImage', function(data) {
      if (/http/g.test(data)) {
        UserProfile.update({user: {image_original_path: data}}).then(function() {
          $scope.userProfile.avatar = {
            preview: data
          };
          UserProfile.clear();
        });
      }
    });
  }

  ProfileCtrl.$inject = ['$scope', '$rootScope', 'UserProfile'];
  angular.module('powurApp').controller('ProfileCtrl', ProfileCtrl);
})();
