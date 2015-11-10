;(function() {
  'use strict';

  function QualifyCtrl($scope, $rootScope, $http, $location, $routeParams, UserProfile, SolarCityZipValidator, CommonService) {
    $scope.zip = {};

    $scope.proposalStatus = '';
    /*
    Proposal Statuses:
    - invalidZip : ZIP was entered; SC API returned "out of territory"
    - new : ZIP was entered; SC API returned "in territory"
    - saved : Proposal was saved successfully
    - edit : Advocate clicked "edit" on "saved" screen
    - submitted : Advocate clicked "submit" on "saved" screen
    */

    //
    // Utility Functions
    //
    function getAction(actions, name) {
      for (var i in actions) {
        if (actions[i].name === name) {
          return actions[i];
        }
      }
      return;
    }

    // Determine which fields from action's fields are dynamic "product fields"
    function setProductFields(formAction) {
      var productFields = [];
      for (var i in formAction.fields) {
        if (formAction.fields[i].product_field) {
          productFields.push(formAction.fields[i]);
        }
      }
      return productFields;
    }

    // Set values from action's fields' values
    function setFormValues(formAction) {
      var formValues = {};
      for (var i in formAction.fields) {
        var key = formAction.fields[i].name;
        var value = formAction.fields[i].value;
        formValues[key] = (value) || '';
      }
      return formValues;
    }

    //
    // Controller Functions
    //
    $scope.validateZip = function() {
      $scope.disableZipInput = true;
      $scope.zipErrorMessages = {};

      var zipRegEx = /^[0-9]{5}$/;
      if (zipRegEx.test($scope.zip.code)) {
        SolarCityZipValidator.check({
          zip: $scope.zip.code
        }).then(function(data){
          if (data.properties.is_valid) {
            $scope.proposalStatus = 'new';
            $scope.proposal = {};
            $scope.proposal.zip = $scope.zip.code;
            $scope.disableProposalForm = false;
          } else {
            $scope.proposalStatus = 'invalidZip';
          }
        });
      } else {
        $scope.zipErrorMessages = {
          zip: 'Please enter a valid 5-digit ZIP code.'
        };
        $scope.disableZipInput = false;
      }
    };

    $scope.clearZip = function() {
      $scope.zip = {};
      $scope.disableZipInput = false;
      $scope.proposalStatus = '';
    };

    $scope.sendToSignIn = function() {
      // $rootScope.redirectAfterSignIn = {};
      // $rootScope.redirectAfterSignIn.destination = '/qualify';
      // $rootScope.redirectAfterSignIn.properties = {zip: $scope.zip.code};
      // $location.path('/next/login/');
      window.location = '/next/login/';
    };

    $scope.saveProposal = function() {
      $scope.formErrorMessages = {};
      $scope.disableProposalForm = true;

      var actionCallback = function(data) {
        $scope.savedProposalData = data.properties;

        // Get 'Submit Proposal' Action
        $scope.submitProposalAction = getAction(data.actions, 'submit');

        // Get 'Update Proposal' Action (for Edit)
        $scope.updateProposalAction = getAction(data.actions, 'update');

        if (data.error) {
          $scope.formErrorMessages[data.error.input] = data.error.message;
          $scope.disableProposalForm = false;
          return;
        }
        $scope.proposalStatus = 'saved';
      };

      // Execute create/update action
      if ($scope.proposal) {
        if ($scope.proposalStatus === 'new') {
          CommonService.execute($scope.createProposalAction, $scope.proposal).then(actionCallback);
        } else if ($scope.proposalStatus === 'edit') {
          CommonService.execute($scope.updateProposalAction, $scope.proposal).then(actionCallback);
        }
      }
    };

    $scope.submitProposal = function() {
      if ($scope.submitProposalAction) {
        CommonService.execute($scope.submitProposalAction).then(function(data) {
          $scope.proposalStatus = 'submitted';
        });
      }
    };

    $scope.editProposal = function() {
      $scope.proposal = setFormValues($scope.updateProposalAction);
      $scope.proposalStatus = 'edit';
      $scope.disableProposalForm = false;
    };

    $scope.reset = function() {
      $scope.proposal = {};
      $scope.clearZip();
      $scope.proposalStatus = '';
    };

    //
    // Initialization Functions
    //

    // Handle Redirects from Sign-In Page
    if ($rootScope.redirectAfterSignIn && $rootScope.redirectAfterSignIn.destination === '/qualify') {
      $scope.zip.code = $rootScope.redirectAfterSignIn.properties.zip;
      $scope.redirectAfterSignIn = null;
      $scope.validateZip();
    }

    // Get Current User
    if ($rootScope.isSignedIn) {
      UserProfile.get().then(function(data) {
        $rootScope.currentUser = data.properties;

        // Get 'Create Proposal' Action
        if (/\/qualify/.test($location.path())) {
          $http({
            method: 'GET',
            url: '/u/users/' + data.properties.id + '/leads',
          }).success(function(data) {
            $scope.createProposalAction = getAction(data.actions, 'create');
            $scope.productFields = setProductFields($scope.createProposalAction);
          });
        }
      });
    }
  }

  QualifyCtrl.$inject = ['$scope', '$rootScope', '$http', '$location', '$routeParams', 'UserProfile', 'SolarCityZipValidator', 'CommonService'];
  angular.module('powurApp').controller('QualifyCtrl', QualifyCtrl);
})();
