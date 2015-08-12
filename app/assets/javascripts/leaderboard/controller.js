;(function() {
  'use strict';

  function LeaderboardCtrl($scope, CommonService) {
    $scope.redirectUnlessSignedIn();

    //Populate Leaderboard
    CommonService.execute({
      href: '/u/users.json?',
      params: {
        sort: 'lead_count',
        item_totals: 'lead_count',
        user_totals: 'true',
        limit: 20
      }
    }).then(function(data){
      for (var i = 0; i < data.entities.length; i++){
        data.entities[i] = data.entities[i].properties;
        data.entities[i].defaultAvatarThumb = randomThumb();
      }
      $scope.leaders = data.entities;
      console.log($scope.leaders)
    });

    $scope.dateHeader = function(){
      var d = new Date();
      return legacyMonths[d.getMonth()] + ' ' + d.getFullYear();
    }
  }

  LeaderboardCtrl.$inject = ['$scope','CommonService'];
  angular.module('powurApp').controller('LeaderboardCtrl', LeaderboardCtrl);
})();