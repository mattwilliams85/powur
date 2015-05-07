;(function() {
  'use strict';

  function UserStaticContentCtrl($scope, $location, UserProfile) {
    // $scope.redirectUnlessSignedIn();

    UserProfile.get().then(function(user) {
      $scope.currentUser = user;
    });

    $scope.removePiler();

    $scope.isMenuActive = false;
    $scope.hideMenuClick = function() {
      $scope.isMenuActive = false;
      $('#pp-nav').fadeIn();
    };
    $scope.showMenuClick = function() {
      $scope.isMenuActive = true;
      $('#pp-nav').fadeOut();
    };

    this.init($scope, $location);
    this.fetch($scope);
  }

  UserStaticContentCtrl.prototype.init = function($scope, $location) {
    // Setting mode based on the url
    $scope.mode = '';
    if (/\/customer-faq$/.test($location.path())) return $scope.mode = 'customer-faq';
    if (/\/advocate-faq$/.test($location.path())) return $scope.mode = 'advocate-faq';
  };

  UserStaticContentCtrl.prototype.fetch = function($scope) {
    if ($scope.mode === 'customer-faq' || $scope.mode === 'advocate-faq') {
      $scope.faqHeaderTitle = $scope.mode === 'customer-faq' ?
        'Powur Customer FAQ' :
        'Powur Advocate FAQ';
    }
  };

  UserStaticContentCtrl.$inject = ['$scope', '$location', 'UserProfile'];
  angular.module('powurApp').controller('UserStaticContentCtrl', UserStaticContentCtrl);
})();
