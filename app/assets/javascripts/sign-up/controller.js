;(function() {
  'use strict';

  function SignUpCtrl($scope, $rootScope, $http, $location, $routeParams, CommonService, UserProfile) {
    $scope.redirectIfSignedIn();
    $scope.legacyImagePaths = legacyImagePaths;

    //
    // Utility functions
    //

    function getAction(actions, name) {
      for (var i in actions) {
        if (actions[i].name === name) {
          return actions[i];
        }
      }
      return;
    }

    function setFieldValuesFromAction(action) {
      var fieldsWithValues = {};
      for (var i in action.fields) {
        fieldsWithValues[action.fields[i].name] = action.fields[i].value;
      }
      return fieldsWithValues;
    }

    //
    // Controller Functions
    //

    // Validate invite when parsing URL or after entering code into form
    $scope.validateInvite = function() {
      if ($scope.invite && $scope.inviteCode) {
        CommonService.execute({
          method: 'POST',
          href: '/invite/validate.json'
        }, {
          code: $scope.inviteCode
        }).then(function(data) {
          if (data.error) {
            $scope.invite.error = data.error;
          } else {
            $scope.invite = data;
            $scope.signUpAction = getAction($scope.invite.actions, 'accept_invite');
            $scope.user = setFieldValuesFromAction($scope.signUpAction)
            $scope.applicationAndAgreementLink = data.properties.latest_terms.document_path;
          }
        });
      }
    }

    // Sign Up
    $scope.signUp = function() {
      $scope.disableSubmit = true;
      if ($scope.user) {
        CommonService.execute($scope.signUpAction, $scope.user).then(signUpCallback);
      }
    }

    // Sign Up callback
    function signUpCallback(data) {
      $scope.formErrorMessages = {};
      if (data.errors) {
        $.each(data.errors, function(key, errors) {
          var errorMessage = errors[0];
          if (errorMessage) {
            $scope.formErrorMessages[key] = errors[0];
          }
          $scope.disableSubmit = false;
        });
      } else {
        // Sign User In after Signing Up
        $rootScope.isSignedIn = true;
        $rootScope.currentUser = data;
        $scope.redirectIfSignedIn();
      }
    }

    this.fetch($scope, $routeParams);
  }

  SignUpCtrl.prototype.fetch = function($scope, $routeParams) {
    $scope.invite = {};
    $scope.inviteCode = $routeParams.inviteCode;
    if ($scope.inviteCode) $scope.validateInvite();
  }

  SignUpCtrl.$inject = ['$scope', '$rootScope', '$http', '$location', '$routeParams', 'CommonService', 'UserProfile']
  angular.module('powurApp').controller('SignUpCtrl', SignUpCtrl);


})();