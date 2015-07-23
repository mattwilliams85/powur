;(function() {
  'use strict';

  function LandingCtrl($scope, $http) {
    $scope.redirectUnlessSignedIn();

    $scope.index = {};

    $http({
      method: 'GET',
      url: '/a'
    }).success(function success(data) {
      $scope.index.data = data;
    });
  }

  LandingCtrl.$inject = ['$scope', '$http'];
  angular.module('powurApp').controller('LandingCtrl', LandingCtrl);
})();
