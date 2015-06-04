;(function() {
  'use strict';

  function LandingCtrl($scope, $rootScope, $http, $location, $routeParams, $timeout, $interval, UserProfile, CommonService) {
    $scope.redirectIfSignedIn();

    $scope.showValidationMessages = false;
    $scope.isSubmitDisabled = false;

    $scope.leftMenu = {};

    $scope.legacyImagePaths = legacyImagePaths;

    $scope.signIn = function() {
      if ($scope.user && $scope.user.email && $scope.user.password) {
        UserProfile.signIn({
          email: $scope.user.email,
          password: $scope.user.password,
          remember_me: $scope.user.remember_me
        }).then(function(data) {
          if (data.error) {
            $scope.showModal('Oops, wrong email or password');
          } else {
            $rootScope.isSignedIn = true;
            $rootScope.currentUser = data;
            $scope.redirectIfSignedIn();
          }
        });
      } else {
        $scope.showValidationMessages = true;
      }
    };

    $scope.validateInvite = function() {
      var code;
      if ($scope.invite && $scope.invite.code) {
        CommonService.execute({
          method: 'POST',
          href: '/invite/validate.json'
        }, {
          code: $scope.invite.code
        }).then(function(data) {
          if (data.error) {
            $scope.invite = {};
            $scope.user = {};
            $scope.invite.error = data.error;
          } else {
            code = $scope.invite.code;
            $scope.invite = data;
            console.log($scope.invite);
            $scope.invite.code = code;
            $scope.user.first_name = data.properties.first_name;
            $scope.user.last_name = data.properties.last_name;
            $scope.user.email = data.properties.email;
          }
        });
      }
    };

    function signUpCallback(data) {
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
        $scope.showModal('Congratulations! You\'ve successfully signed up for Powur.<br>You may now sign in with your email and password.');
      }
      $scope.isSubmitDisabled = false;
    }

    $scope.signUp = function() {
      if ($scope.user) {
        $scope.isSubmitDisabled = true;
        var action;
        for (var i in $scope.invite.actions) {
          if ($scope.invite.actions[i].name === 'create_account') {
            action = $scope.invite.actions[i];
          }
        }
        $scope.user.code = $scope.invite.properties.id;
        CommonService.execute(action, $scope.user).then(signUpCallback);
      }
    };

    $scope.clearInviteValidationForm = function() {
      $scope.invite = {};
      $scope.user = {};
      $scope.invite.er
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
          $scope.showModal('We received your request. You\'ll get an email if we have an account associated with it.');
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
            $scope.showModal(data.error.message);
          } else {
            $location.path('/sign-in');
            $scope.showModal(data.properties._message.confirm);
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
    this.fetch($scope, $rootScope, $http, $location, $interval, $routeParams, $timeout);
  }

  LandingCtrl.prototype.init = function($scope, $location, $timeout) {
    // Setting mode based on the url
    $scope.mode = '';
    if (/\/home$/.test($location.path())) return $scope.mode = 'home';
    if (/\/sign-in$/.test($location.path())) return $scope.mode = 'sign-in';
    if (/\/customer-faq$/.test($location.path())) return $scope.mode = 'customer-faq';
    if (/\/advocate-faq$/.test($location.path())) return $scope.mode = 'advocate-faq';
    if (/\/sign-up/.test($location.path())) return $scope.mode = 'sign-up';
    if (/\/reset-password/.test($location.path())) return $scope.mode = 'reset-password';
  };


  LandingCtrl.prototype.fetch = function($scope, $rootScope, $http, $location, $interval, $routeParams, $timeout) {
    if ($scope.mode === 'sign-in') {
      $scope.signInPage = true;
    } else if ($scope.mode === 'customer-faq' || $scope.mode === 'advocate-faq') {
      $scope.faqHeaderTitle = $scope.mode === 'customer-faq' ?
        'Powur Customer FAQ' :
        'Powur Advocate FAQ';
    } else if ($scope.mode === 'sign-up') {
      $scope.invite = {};
      $scope.user = {};
      $scope.invite.code = $routeParams.inviteCode;
      if ($scope.invite.code) $scope.validateInvite();
    } else if ($scope.mode === 'reset-password') {
      $http.post('/password/validate_reset_token.json', {
        token: $routeParams.resetPasswordToken
      }).
      success(function(data){
        $scope.validResetToken = true;
      }).
      error(function(data){
        $location.path('/sign-in');
        $scope.showModal("Your Password Reset Link is invalid or has already been used.")
      });
    }
  };


  LandingCtrl.$inject = ['$scope', '$rootScope', '$http', '$location', '$routeParams', '$timeout', '$interval', 'UserProfile', 'CommonService'];
  angular.module('powurApp').controller('LandingCtrl', LandingCtrl);

})();
