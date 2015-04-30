;(function() {
  'use strict';

  function EarningsCtrl($scope, $location, UserProfile) {
    $scope.redirectUnlessSignedIn();

    UserProfile.get().then(function(user) {
      $scope.currentUser = user;
      if (user.require_enrollment) {
        $location.path('/university');
        $scope.showModal($scope.enrollmentRequirementMessage);
        return;
      }
    });
  }

  EarningsCtrl.$inject = ['$scope', '$location', 'UserProfile'];
  angular.module('powurApp').controller('EarningsCtrl', EarningsCtrl);
})();
