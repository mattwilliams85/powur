;(function() {
  'use strict';

  function DashboardTeamCtrl($scope) {
    $scope.redirectUnlessSignedIn();
  }

  DashboardTeamCtrl.$inject = ['$scope', '$location'];
  angular.module('powurApp').controller('DashboardTeamCtrl', DashboardTeamCtrl);

})();
