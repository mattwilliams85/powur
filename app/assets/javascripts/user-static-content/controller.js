;(function() {
  'use strict';

  function UserStaticContentCtrl($scope, $rootScope, $location, $http, UserProfile, CommonService) {
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
    this.fetch($scope, $rootScope);
  }

  UserStaticContentCtrl.prototype.init = function($scope, $location) {
    // Setting mode based on the url
    $scope.mode = '';
    if (/\/customer-faq$/.test($location.path())) return $scope.mode = 'customer-faq';
    if (/\/advocate-faq$/.test($location.path())) return $scope.mode = 'advocate-faq';
    if (/\/contact$/.test($location.path())) return $scope.mode = 'contact';
  };

  UserStaticContentCtrl.prototype.fetch = function($scope, $rootScope) {
    if ($scope.mode === 'customer-faq' || $scope.mode === 'advocate-faq') {
      $scope.faqHeaderTitle = $scope.mode === 'customer-faq' ?
        'Powur Customer FAQ' :
        'Powur Advocate FAQ';
    } else if ($scope.mode === 'contact') {
      $rootScope.$watch('currentUser', function(data) {
        if (data.id) $scope.getSponsors();
      });
    }
  };

  UserStaticContentCtrl.$inject = ['$scope', '$rootScope', '$location', '$http', 'UserProfile', 'CommonService'];
  angular.module('powurApp').controller('UserStaticContentCtrl', UserStaticContentCtrl);
})();
