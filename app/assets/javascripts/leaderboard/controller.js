;(function() {
  'use strict';

  function LeaderboardCtrl($scope, CommonService) {
    $scope.redirectUnlessSignedIn();

    //Populate Leaderboard
    CommonService.execute({
      href: '/u/users/leaderboard.json?',
      params: {
        sort: 'proposals_count',
        user_totals: 'true',
        limit: 20
      }
    }).then(function(data){
      for (var i = 0; i < data.entities.length; i++){
        data.entities[i] = data.entities[i].properties;
        data.entities[i].defaultAvatarThumb = randomThumb();
      }
      $scope.leaders = data.entities;
    });

    $scope.dateHeader = function(){
      var d = new Date();
      return legacyMonths[d.getMonth()] + ' ' + d.getFullYear();
    }
  }

  LeaderboardCtrl.$inject = ['$scope','CommonService'];
  angular.module('powurApp').controller('LeaderboardCtrl', LeaderboardCtrl);
})();