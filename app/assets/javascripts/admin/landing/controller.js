;(function() {
  'use strict';

  function LandingCtrl($scope, $http) {
    $scope.redirectUnlessSignedIn();

    $scope.index = {};
    $scope.daysAgoOptions = [
      { label: 'Since Midnight', value: 1 },
      { label: 'Last 7 days', value: 7 },
      { label: 'Last 10 days', value: 10 },
      { label: 'Last 30 days', value: 30 }
    ];

    $scope.daysAgo = 1;

    $scope.getData = function() {
      $http({
        method: 'GET',
        url: '/a',
        params: {
          days_ago: $scope.daysAgo
        }
      }).success(function success(data) {
        $scope.index.data = data;
      });
    };

    $scope.getData();
  }

  LandingCtrl.$inject = ['$scope', '$http'];
  angular.module('powurApp').controller('LandingCtrl', LandingCtrl);
})();
