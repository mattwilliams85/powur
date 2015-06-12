;(function() {
  'use strict';

  function MembershipsCtrl($scope, UserProfile) {
    $scope.redirectUnlessSignedIn();

    UserProfile.get().then(function(user) {
      $scope.currentUser = user;
    });
  }

  MembershipsCtrl.$inject = ['$scope', 'UserProfile'];
  angular.module('powurApp').controller('MembershipsCtrl', MembershipsCtrl);
})();
