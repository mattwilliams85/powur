'use strict';

function DashboardTeamCtrl($scope, $location) {
  $scope.redirectUnlessSignedIn();

}

DashboardTeamCtrl.$inject = ['$scope', '$location'];
sunstandControllers.controller('DashboardTeamCtrl', DashboardTeamCtrl);
