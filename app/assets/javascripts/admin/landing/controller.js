;(function() {
  'use strict';

  function LandingCtrl($scope) {
    $scope.redirectUnlessSignedIn();

  };

  LandingCtrl.$inject = ['$scope'];
  angular.module('powurApp').controller('LandingCtrl', LandingCtrl);

})();
