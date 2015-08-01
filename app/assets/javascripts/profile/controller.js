;(function() {
  'use strict';

  function ProfileCtrl($scope, $rootScope, $anchorScroll, UserProfile, $http) {
    $scope.redirectUnlessSignedIn();

    UserProfile.get().then(function(data) {
      $rootScope.currentUser = data.properties;
    });

    $scope.userProfile = {};
    $http({
      method: 'GET',
      url: '/u/profile'
    }).success(function(data) {
      $scope.userProfile = data.properties;
      $scope.actions = data.actions;
    });

    $scope.legacyImagePaths = legacyImagePaths;

    $scope.updateProfile = function() {
      if ($scope.userProfile) {
        UserProfile.update({user: $scope.userProfile}).then(function() {
          $anchorScroll();
          $scope.showModal('Personal information successfully updated');
        });
      }
    };

    $scope.updatePassword = function() {
      if ($scope.password) {
        UserProfile.updatePassword($scope.password).then(function(data) {
          $anchorScroll();
          if (data.error) {
            $scope.showModal(data.error.message);
          } else {
            $scope.showModal('Password successfully updated');
            $scope.password = {};
          }
        });
      }
    };

    $scope.setUpEwalletAccount = function() {
      $scope.isSubmitDisabled = true;
      var action = getAction($scope.actions, 'create_ewallet');

      return $http({
        method: action.method,
        url: action.href
      }).success(function(data) {
        $scope.isSubmitDisabled = false;
        $scope.userProfile = data.properties;
      }).error(function() {
        $scope.isSubmitDisabled = false;
      });
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

  // Utility Functions
  function getAction(actions, name) {
    for (var i in actions) {
      if (actions[i].name === name) {
        return actions[i];
      }
    }
    return;
  }

  ProfileCtrl.$inject = ['$scope', '$rootScope', '$anchorScroll', 'UserProfile', '$http'];
  angular.module('powurApp').controller('ProfileCtrl', ProfileCtrl);
})();
