;(function() {
  'use strict';

  function LandingCtrl($scope, $http, $timeout) {
    $scope.redirectUnlessSignedIn();

    $scope.index = {};

    $scope.getData = function() {
      $http({
        method: 'GET',
        url: '/a',
        params: {
          date_since: $scope.dateSince,
          date_until: $scope.dateUntil
        }
      }).success(function success(data) {
        $scope.index.data = data;
      });
    };

    $scope.getData();
    $timeout(function() {
      var format = 'yy-mm-dd';
      $('#datepicker_since').datepicker({
        dateFormat: format
      });
      $('#datepicker_until').datepicker({
        dateFormat: format
      });

      // Set default dates
      var today = new Date();
      var month = ('0' + (today.getMonth() + 1)).slice(-2);
      var todayStr = today.getFullYear() + '-' + month + '-' + today.getDate();
      $scope.dateSince = todayStr;
      $scope.dateUntil = todayStr;
    });
  }

  LandingCtrl.$inject = ['$scope', '$http', '$timeout'];
  angular.module('powurApp').controller('LandingCtrl', LandingCtrl);
})();
