'use strict';

function LandingCtrl($scope, $rootScope, $http, $location, $timeout, $anchorScroll) {
  $scope.redirectToDashboardIfSignedIn();

  $scope.isMenuActive = false;
  $scope.showValidationMessages = false;

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

  $scope.signIn = function() {
    var csrfToken, headers;

    if ($scope.user && $scope.user.email && $scope.user.password) {
      csrfToken = $('meta[name="csrf-token"]').attr('content');
      headers = {'X-CSRF-Token': csrfToken};

      $http.post('/login.json', {email: $scope.user.email, password: $scope.user.password, remember_me: $scope.user.remember_me}, {headers: headers}).
      success(function(data) {
        if (data.error) {
          $("<div class='reveal-modal' data-reveal><h3>Oops, wrong email or password</h3><a class='close-reveal-modal'>&#215;</a></div>").foundation('reveal', 'open');
          $(document).foundation();
        } else {
          $rootScope.isSignedIn = true;
          $scope.redirectToDashboardIfSignedIn();
        }
      }).
      error(function() {
        console.log('Sign In Error');
      });
    } else {
      $scope.showValidationMessages = true;
    }
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


LandingCtrl.$inject = ['$scope', '$rootScope', '$http', '$location', '$timeout', '$anchorScroll'];
sunstandControllers.controller('LandingCtrl', LandingCtrl);
