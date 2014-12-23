'use strict';

function LandingCtrl($scope, $location, $timeout, $anchorScroll) {
  $scope.redirectToDashboardIfSignedIn();

  $scope.isMenuActive = false;

  $scope.invertHeaderColor = function() {
    var docEl = document.documentElement;
    var $header;
    var height = $(window).height() - 20;
    window.onscroll = function headerScrollInvert() {
      var sTop = (this.pageYOffset || docEl.scrollTop) - (docEl.clientTop || 0);
      $header = document.getElementById('sun_landing_header');

      if (!$header) return;

      if (sTop > height) {
        $header.setAttribute('class', 'invert');
      } else {
        $header.setAttribute('class', '');
      }
    };
  };

  $scope.gotoAnchor = function(id) {
    if ($location.hash() !== id) {
      $location.hash(id);
    } else {
      $anchorScroll();
    }
  };

  $scope.hideMenuClick = function() {
    $scope.isMenuActive = false;
  };

  $scope.showMenuClick = function() {
    $scope.isMenuActive = true;
  };

  this.init($scope, $location, $timeout);
  this.fetch($scope);
}


LandingCtrl.prototype.init = function($scope, $location, $timeout) {
  $timeout(function() {
    $scope.invertHeaderColor();
  }, 2000);

  // Setting mode based on the url
  $scope.mode = 'index';
  if (/\/sign-in$/.test($location.path())) $scope.mode = 'sign-in';
};


LandingCtrl.prototype.fetch = function($scope) {
  if ($scope.mode === 'sign-in') {
    // Do something here only for sign in page
    $scope.signInPage = true;
  }
};


LandingCtrl.$inject = ['$scope', '$location', '$timeout', '$anchorScroll'];
sunstandControllers.controller('LandingCtrl', LandingCtrl);
