'use strict';

function LandingCtrl($scope, $rootScope, $http, $location, $routeParams, $timeout, $interval, Invite, Geo) {
  $scope.redirectToDashboardIfSignedIn();
  $scope.showValidationMessages = false;
  $scope.isSubmitDisabled = false;

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

  $scope.validateInvite = function() {
    var code;
    if ($scope.invite && $scope.invite.code) {
      Invite.validate($scope.invite.code).then(function(data) {
        if (data.error) {
          $scope.invite = {};
          $scope.user = {};
          $scope.invite.error = data.error;
        } else {
          code = $scope.invite.code;
          $scope.invite = data;
          $scope.invite.code = code;
          $scope.user.first_name = data.properties.first_name;
          $scope.user.last_name = data.properties.last_name;
          $scope.user.email = data.properties.email;
        }
      });
    }
  };

  var signUpCallback = function(data) {
    $scope.formErrorMessages = {};
    if (data.errors) {
      $.each(data.errors, function(key, errors) {
        // Only take first error message from the array
        var errorMessage = errors[0];
        if (errorMessage) {
          $scope.formErrorMessages[key] = errors[0];
        }
      });
    } else {
      $location.path('/sign-in');
      $('<div class=\'reveal-modal\' data-reveal><h3>You\'ve successfully Signed Up. Now you may Sign In.</h3><a class=\'close-reveal-modal\'>&#215;</a></div>').foundation('reveal', 'open');
      $(document).foundation();
    }
    $scope.isSubmitDisabled = false;
  };
  $scope.signUp = function() {
    if ($scope.user) {
      $scope.isSubmitDisabled = true;
      var path;
      for (var i in $scope.invite.actions) {
        if ($scope.invite.actions[i].name === 'create_account') {
          path = $scope.invite.actions[i].href;
        }
      }
      Invite.signUp($scope.invite.properties.id, $scope.user, path).then(signUpCallback);
    }
  };

  $scope.clearInviteValidationForm = function() {
    $scope.invite = {};
    $scope.user = {};
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
  this.fetch($scope, $interval, $routeParams, Geo);
}


LandingCtrl.prototype.init = function($scope, $location, $timeout) {

  // Runs page-piler after intro
  $('html').removeClass('piling-on');
  $('#pp-nav').hide();
  if ($location.path() === '/home') {
    var pilerTimer = $timeout(function() {
      $('.arrow-box').animate({
        bottom: "3em"
      }, 500, "easeOutBounce" );
      $scope.readyPiler();
    }, 4500);
  }

  if ($location.path() === '/sign-up') {
    $scope.readyPiler();
    var pilerTimer = $timeout(function() {
      $('.arrow-box').animate({
        bottom: "3em"
      }, 500, "easeOutBounce" );
    }, 3000);

    // Cancels if user leaves page
    $scope.$on('$locationChangeStart', function(){
      $timeout.cancel(pilerTimer);
    });
  } else {
    $('.arrow-box').css('bottom','3em')
  }

  // Cancels if user leaves page
  $scope.$on('$locationChangeStart', function(){
    $timeout.cancel(pilerTimer);
  });

  // Setting mode based on the url
  $scope.mode = '';
  if (/\/home$/.test($location.path())) return $scope.mode = 'home';
  if (/\/sign-in$/.test($location.path())) return $scope.mode = 'sign-in';
  if (/\/customer-faq$/.test($location.path())) return $scope.mode = 'customer-faq';
  if (/\/advocate-faq$/.test($location.path())) return $scope.mode = 'advocate-faq';
  if (/\/sign-up/.test($location.path())) return $scope.mode = 'sign-up';

};


LandingCtrl.prototype.fetch = function($scope, $interval, $routeParams, Geo) {
  if ($scope.mode === 'home') {

    // Only for home page
    $scope.currentHomeSlide = 0;
    var sliderStop = $interval(function() {
      $scope.currentHomeSlide += 1;
      if ($scope.currentHomeSlide >= 2) {
        $interval.cancel(sliderStop);
        sliderStop = undefined;
      }
    }, 2000);

  } else if ($scope.mode === 'sign-in') {
    // Only for sign in page
    $scope.signInPage = true;
  } else if ($scope.mode === 'customer-faq' || $scope.mode === 'advocate-faq') {
    $('#pp-nav').hide();

    // Only for faq pages
    $scope.activeFAQItemId = 'faq_item_1';
    $scope.faqHeaderTitle = $scope.mode === 'customer-faq' ?
      'Powur Customer FAQ' :
      'Powur Advocate FAQ';
  } else if ($scope.mode === 'sign-up') {
    // Only for sign up page
    $scope.invite = {};
    $scope.user = {};
    $scope.countries = Geo.countries();
    $scope.states = Geo.states();
    $scope.invite.code = $routeParams.inviteCode;
    if ($scope.invite.code) $scope.validateInvite();
  }
};


LandingCtrl.$inject = ['$scope', '$rootScope', '$http', '$location', '$routeParams', '$timeout', '$interval', 'Invite', 'Geo'];
sunstandControllers.controller('LandingCtrl', LandingCtrl);
