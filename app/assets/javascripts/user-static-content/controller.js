;(function() {
  'use strict';

  function UserStaticContentCtrl($scope, $rootScope, $location, $http, $interval, $timeout, UserProfile, CommonService) {
    $scope.leftMenu = {};

    $scope.legacyImagePaths = legacyImagePaths;

    UserProfile.get().then(function(data) {
      $rootScope.currentUser = data.properties;
    });

    // getSponsors is used on /contact page to retrieve Team Leader and Coach users
    $scope.getSponsors = function() {
      $http({
        method: 'GET',
        url: '/u/users/' + $rootScope.currentUser.id + '/sponsors.json',
      }).success(function(res) {
        $scope.teamLeader = res.entities[0];
        $scope.coach = res.entities[1];
      }).error(function(err) {
        console.log('エラー', err);
      });
    };

    this.init($scope, $location);
    this.fetch($scope, $rootScope, $interval, $timeout);
  }

  UserStaticContentCtrl.prototype.init = function($scope, $location) {
    // Setting mode based on the url
    $scope.mode = '';
    if (/\/customer-faq$/.test($location.path())) return $scope.mode = 'customer-faq';
    if (/\/advocate-faq$/.test($location.path())) return $scope.mode = 'advocate-faq';
    if (/\/contact$/.test($location.path())) return $scope.mode = 'contact';
    if (/\/preview$/.test($location.path())) return $scope.mode = 'preview';
  };

  UserStaticContentCtrl.prototype.fetch = function($scope, $rootScope, $interval, $timeout) {
    if ($scope.mode === 'customer-faq' || $scope.mode === 'advocate-faq') {
      $scope.faqHeaderTitle = $scope.mode === 'customer-faq' ?
        'Powur Customer FAQ' :
        'Powur Advocate FAQ';
    } else if ($scope.mode === 'contact') {
      $rootScope.$watch('currentUser', function(data) {
        if (data.id) $scope.getSponsors();
      });
    } else if ($scope.mode === 'preview') {
      vidTimer();
      $timeout(function(){
        $('#sun_header_guest').addClass('invert');
      })
    }

    function vidTimer(){
      var timer = $interval(function(){
        var date = new Date;
        var seconds = 59 - date.getSeconds();
        var minutes = 59 - date.getMinutes();

        if (minutes == 0 && seconds == 0) {
          $interval.cancel(timer);
          $('#video-1').get(0).play();
        }

        if (seconds < 10) seconds = '0' + seconds;
        if (minutes < 10) minutes = '0' + minutes;
        
        $scope.timer = minutes + ':' + seconds;
      }, 1000)
    }

  };

  UserStaticContentCtrl.$inject = ['$scope', '$rootScope', '$location', '$http', '$interval', '$timeout', 'UserProfile', 'CommonService'];
  angular.module('powurApp').controller('UserStaticContentCtrl', UserStaticContentCtrl);
})();
