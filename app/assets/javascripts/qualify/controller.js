;(function() {
  'use strict';

  function QualifyCtrl($scope, $rootScope, $http, $location, $routeParams, UserProfile, SolarCityZipValidator, CommonService) {
    $scope.zip = {};

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

    //
    // Controller Functions
    //
    $scope.validateZip = function() {
      $scope.disableZipInput = true;
      SolarCityZipValidator.check({
        zip: $scope.zip.code
      }).then(function(data){
        if (data.valid) {
          $scope.zip.inTerritory = true;
          $scope.proposal = {};
          $scope.proposal.zip = $scope.zip.code;
          $scope.disableProposalForm = false;
        } else {
          $scope.zip.inTerritory = false;
        }
      });
    };

    $scope.clearZip = function() {
      $scope.zip = {};
      $scope.disableZipInput = false;
    };

    $scope.sendToSignIn = function() {
      $rootScope.redirectAfterSignIn = {};
      $rootScope.redirectAfterSignIn.destination = '/qualify';
      $rootScope.redirectAfterSignIn.properties = {zip: $scope.zip.code};
      $location.path('/sign-in');
    };

    $scope.saveProposal = function() {
      $scope.formErrorMessages = {};
      $scope.disableProposalForm = true;
      if ($scope.proposal && $('#proposal-form')[0].checkValidity()) {
        CommonService.execute($scope.createProposalAction, $scope.proposal).then(function(data) {
          $scope.savedProposalData = data.properties;
          if (data.error) {
            $scope.formErrorMessages[data.error.input] = data.error.message;
            return;
          }
          $scope.proposalSaved = true;
        });
      }
    };

    $scope.reset = function() {
      $scope.proposal = {};
      $scope.clearZip();
      $scope.proposalSaved = false;
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
    UserProfile.get().then(function(user) {
      $rootScope.currentUser = user;

      // Get 'Create Proposal' Action
      $http({
        method: 'GET',
        url: '/u/users/' + user.id + '/quotes',
      }).success(function(data) {
        $scope.createProposalAction = getAction(data.actions, 'create');
        $scope.productFields = setProductFields($scope.createProposalAction)
      });

    });
  }

  QualifyCtrl.$inject = ['$scope', '$rootScope', '$http', '$location', '$routeParams', 'UserProfile', 'SolarCityZipValidator', 'CommonService'];
  angular.module('powurApp').controller('QualifyCtrl', QualifyCtrl);
})();
