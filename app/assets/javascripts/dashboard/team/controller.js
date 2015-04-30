;(function() {
  'use strict';

  function DashboardTeamCtrl($scope, User) {
    $scope.redirectUnlessSignedIn();

    $scope.teamSection.showTeamMember = function(userId) {

    };

    $scope.teamSection.newInvite = function() {

    };

    return User.list().then(function(items) {
      $scope.teamMembers = items.entities;
    });
  }

  DashboardTeamCtrl.$inject = ['$scope', 'User'];
  angular.module('powurApp').controller('DashboardTeamCtrl', DashboardTeamCtrl);

})();
