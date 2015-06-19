;(function() {
  'use strict';

  function MembershipsCtrl($scope, $location, $anchorScroll, UserProfile) {
    $scope.redirectUnlessSignedIn();

    UserProfile.get().then(function(user) {
      $scope.currentUser = user;
    });

    $scope.selectMembership = function(item) {
      $scope.showModal('Purchase modal. Coming soon ...');
      $anchorScroll();
    };

    $scope.scrollTo = function(domId) {
      var old = $location.hash();
      $location.hash(domId);
      $anchorScroll();
      $location.hash(old);
    };
  }

  MembershipsCtrl.$inject = ['$scope', '$location', '$anchorScroll', 'UserProfile'];
  angular.module('powurApp').controller('MembershipsCtrl', MembershipsCtrl);
})();
