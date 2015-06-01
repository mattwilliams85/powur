;(function() {
  'use strict';

  function LatestTermsCtrl($scope, UserProfile, CommonService) {
    $scope.redirectUnlessSignedIn();

    //Fetch Profile
    UserProfile.get().then(function(user) {
      $scope.currentUser = user;
    });

  }

  LatestTermsCtrl.$inject = ['$scope', 'UserProfile', 'CommonService'];
  angular.module('powurApp').controller('LatestTermsCtrl', LatestTermsCtrl);
})();