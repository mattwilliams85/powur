;(function() {
  'use strict';

  function QualifyCtrl($scope, $rootScope, $location, $routeParams, UserProfile, SolarCityZipValidator, CommonService) {
    $scope.zip = {};
    $rootScope.isSignedIn = !!SignedIn;

    UserProfile.get().then(function(user) {
      $rootScope.currentUser = user;
    });

    $scope.validateZip = function() {
      SolarCityZipValidator.check({
        zip: $scope.zip.code
      }).then(function(data){
        if (data.valid) {
          $scope.zip.inTerritory = true;
        } else {
          $scope.zip.inTerritory = false;
        }
      });
    };

    $scope.clearZip = function() {
      $scope.zip = {};
    };

  }

  QualifyCtrl.$inject = ['$scope', '$rootScope', '$location', '$routeParams', 'UserProfile', 'SolarCityZipValidator', 'CommonService'];
  angular.module('powurApp').controller('QualifyCtrl', QualifyCtrl);
})();
