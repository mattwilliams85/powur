'use strict';

function LandingCtrl($scope, $rootScope, $http, $location, $routeParams, $timeout, $interval) {
  $scope.redirectToDashboardIfSignedIn();
  $scope.showValidationMessages = false;

  $scope.isMenuActive = false;
  $scope.hideMenuClick = function() {
    $scope.isMenuActive = false;
  };
  $scope.showMenuClick = function() {
    $scope.isMenuActive = true;
  };

  $scope.signIn = function() {
    if ($scope.user && $scope.user.email && $scope.user.password) {
      $http.post('/login.json', {
        email: $scope.user.email,
        password: $scope.user.password,
        remember_me: $scope.user.remember_me
      }, {
        xsrfHeaderName: 'X-CSRF-Token'
      }).
      success(function(data) {
        if (data.error) {
          $('<div class=\'reveal-modal\' data-reveal><h3>Oops, wrong email or password</h3><a class=\'close-reveal-modal\'>&#215;</a></div>').foundation('reveal', 'open');
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

  $scope.resetPassword = function() {
    if ($scope.user && $scope.user.email) {
      $http.post('/password.json', {
        email: $scope.user.email
      }, {
        xsrfHeaderName: 'X-CSRF-Token'
      }).
      success(function() {
        $location.path('/sign-in');
        $('<div class=\'reveal-modal\' data-reveal><h3>We received your request. You\'ll get an email if we have an account associated with it.</h3><a class=\'close-reveal-modal\'>&#215;</a></div>').foundation('reveal', 'open');
        $(document).foundation();
      }).
      error(function() {
        console.log('Reset Password Error');
      });
    } else {
      $scope.showValidationMessages = true;
    }
  };

  $scope.updatePassword = function() {
    if ($scope.user && $scope.user.password && $scope.user.password_confirm) {
      $http.put('/password.json', {
        password: $scope.user.password,
        password_confirm: $scope.user.password_confirm,
        token: $routeParams.resetPasswordToken
      }, {
        xsrfHeaderName: 'X-CSRF-Token'
      }).
      success(function(data) {
        if (data.error) {
          $('<div class=\'reveal-modal\' data-reveal><h3>' + data.error.message + '</h3><a class=\'close-reveal-modal\'>&#215;</a></div>').foundation('reveal', 'open');
          $(document).foundation();
        } else {
          $location.path('/sign-in');
          $('<div class=\'reveal-modal\' data-reveal><h3>' + data.properties._message.confirm + '</h3><a class=\'close-reveal-modal\'>&#215;</a></div>').foundation('reveal', 'open');
          $(document).foundation();
        }
      }).
      error(function() {
        console.log('Reset Password Error');
      });
    } else {
      $scope.showValidationMessages = true;
    }
  };

  this.init($scope, $location, $timeout);
  this.fetch($scope, $interval);
}


LandingCtrl.prototype.init = function($scope, $location, $timeout) {
  $timeout(function() {
    $scope.invertHeaderColor();
  }, 2000);

  // Setting mode based on the url
  $scope.mode = '';
  if (/\/home$/.test($location.path())) return $scope.mode = 'home';
  if (/\/sign-in$/.test($location.path())) return $scope.mode = 'sign-in';
  if (/\/customer-faq$/.test($location.path())) return $scope.mode = 'customer-faq';
  if (/\/advocate-faq$/.test($location.path())) return $scope.mode = 'advocate-faq';
  if (/\/sign-up$/.test($location.path())) return $scope.mode = 'sign-up';
};


LandingCtrl.prototype.fetch = function($scope, $interval) {
  if ($scope.mode === 'home') {
    // Only for home page
    $scope.currentHomeSlide = 0;
    var sliderStop = $interval(function() {
      $scope.currentHomeSlide += 1;
      if ($scope.currentHomeSlide >= 3) {
        $interval.cancel(sliderStop);
        sliderStop = undefined;
      }
    }, 2000);
  } else if ($scope.mode === 'sign-in') {
    // Only for sign in page
    $scope.signInPage = true;
  } else if ($scope.mode === 'customer-faq' || $scope.mode === 'advocate-faq') {
    // Only for faq pages
    $scope.activeFAQItemId = 'faq_item_1';
    $scope.faqHeaderTitle = $scope.mode === 'customer-faq' ?
      'Sunstand Customer FAQ' :
      'Sunstand Advocate FAQ';
  } else if ($scope.mode === 'sign-up') {
    // Only for sign up page
  }
};


LandingCtrl.$inject = ['$scope', '$rootScope', '$http', '$location', '$routeParams', '$timeout', '$interval'];
sunstandControllers.controller('LandingCtrl', LandingCtrl);
