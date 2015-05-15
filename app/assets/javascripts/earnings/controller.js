/* jshint camelcase: false */
;(function() {
  'use strict';

  function EarningsCtrl($scope, $location, $http, UserProfile) {
    $scope.redirectUnlessSignedIn();

    UserProfile.get().then(function(user) {
      $scope.currentUser = user;

      requestEarnings(function successCallback(data) {
        $scope.earningsData = data;

        $scope.search.startMonth = $scope.months[parseFloat(data.properties.start_month) - 1];
        $scope.search.startYear = parseFloat(data.properties.start_year);
        $scope.search.endMonth = $scope.months[parseFloat(data.properties.end_month) - 1];
        $scope.search.endYear = parseFloat(data.properties.end_year);

        $scope.currentWeekTotalEarnings = 0;
        $scope.currentMonthTotalEarnings = 0;
        $scope.accumulatedTotal = parseFloat(data.properties.accumulated_total);
      });
    });

    $scope.years = getPastYearsRange(3);
    $scope.months = [
      'January', 'February', 'March', 'April', 'May', 'June', 'July',
      'August', 'September', 'October', 'November', 'December'
    ];
    $scope.search = {};

    function requestEarnings(cb) {
      var date = new Date();
      $http({
        method: 'GET',
        url: '/u/earnings/summary.json',
        params: {
          user_id: $scope.currentUser.id,
          start_year: date.getFullYear(),
          start_month: date.getMonth() + 1,
          end_year: date.getFullYear(),
          end_month: date.getMonth() + 1,
        }
      }).success(cb);
    }

    function getPastYearsRange(size) {
      var range = [],
          date = new Date(),
          maxYear = date.getFullYear(),
          minYear = maxYear - size;
      for (var i = maxYear; i > minYear; i--) {
        range.push(i);
      }
      return range;
    }
  }

  EarningsCtrl.$inject = ['$scope', '$location', '$http', 'UserProfile'];
  angular.module('powurApp').controller('EarningsCtrl', EarningsCtrl);
})();
