;(function() {
  'use strict';

  function DashboardTeamCtrl($scope, Team) {
    $scope.redirectUnlessSignedIn();

    $scope.teamSection.showTeamMember = function(userId) {

    };

    $scope.teamSection.newInvite = function() {

    };

    return Team.list().then(function(items) {
      $scope.teamMembers = items.entities;
    });
  }

  DashboardTeamCtrl.$inject = ['$scope', 'Team'];
  angular.module('powurApp').controller('DashboardTeamCtrl', DashboardTeamCtrl);

})();
