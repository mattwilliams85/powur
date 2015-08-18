;(function() {
  'use strict';

  function LandingCtrl($scope, $rootScope, $http, $location, $routeParams, $timeout, $interval, UserProfile, CommonService) {
    $scope.redirectIfSignedIn();

    $scope.showValidationMessages = false;
    $scope.isSubmitDisabled = false;

    $scope.leftMenu = {};

    $scope.legacyImagePaths = legacyImagePaths;

    // Sign In

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

    // Reset Password

    $scope.resetPassword = function() {
      if ($scope.user && $scope.user.email) {
        $http.post('/password.json', {
          email: $scope.user.email
        }, {
          xsrfHeaderName: 'X-CSRF-Token'
        }).success(function(data) {
          if (data.error) {
            $scope.showModal(data.error.message);
          } else {
            $location.path('/sign-in');
            $scope.showModal('We received your request. You\'ll get an email if we have an account associated with it.');
          }
        }).error(function() {
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
    if (/\/reset-password/.test($location.path())) return $scope.mode = 'reset-password';
  };


  LandingCtrl.prototype.fetch = function($scope, $rootScope, $http, $location, $interval, $routeParams, $timeout) {
    if ($scope.mode === 'sign-in') {
      $scope.signInPage = true;
    } else if ($scope.mode === 'customer-faq' || $scope.mode === 'advocate-faq') {
      $scope.faqHeaderTitle = $scope.mode === 'customer-faq' ?
        'Powur Customer FAQ' :
        'Powur Advocate FAQ';

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
