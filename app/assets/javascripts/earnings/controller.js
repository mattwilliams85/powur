/* jshint camelcase: false */
;(function() {
  'use strict';

  function EarningsCtrl($scope, $rootScope, $location, $http, UserProfile) {
    $scope.redirectUnlessSignedIn();
    $scope.dateList = {};
    // requestEarnings(function successCallback(data) {
      
    // });

    // $scope.search = {};

    // function requestEarnings(cb) {
    //   $http({
    //     method: 'GET',
    //     url: '/u/earnings/summary.json',
    //     params: {
          
    //     }
    //   }).success(cb);
    // }

    function monthRange(d1, d2) {
      var months;
      months = (d2.getFullYear() - d1.getFullYear()) * 12;
      months -= d1.getMonth() + 1;
      months += d2.getMonth();
      return months <= 0 ? 0 : months;
    }

    var months = [
      'January', 'February', 'March', 'April', 'May', 'June', 'July',
      'August', 'September', 'October', 'November', 'December'
    ];

    function monthList() {
      var startDate = new Date('04/26/2014'); //TEMP
      var range = monthRange(startDate, new Date());

      for (var i = 0; i < range; i ++) {
        var date = new Date();
        date.setMonth(date.getMonth() - i);
        date = new Date(date);
        $scope.dateList[i] = {
          date: new Date(date.setDate(1)),
          string: months[date.getMonth()] + ' ' + date.getFullYear(),
        };
      }
      $scope.search = {date:$scope.dateList[0]};
    }
    monthList();
  }

  EarningsCtrl.$inject = ['$scope', '$rootScope', '$location', '$http', 'UserProfile'];
  angular.module('powurApp').controller('EarningsCtrl', EarningsCtrl);
})();
