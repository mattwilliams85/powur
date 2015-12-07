;(function() {
  'use strict';

  function GetSolarCtrl($scope, $rootScope, $log) {
    $log.debug('GetSolarCtrl');
    
    $scope.legacyImagePaths = legacyImagePaths;
    $scope.zipCode = null;
    
    $scope.checkAvailability = function() {
      
    };
    
    $scope.getSavings = function() {
      
    };
    
    $scope.letsGo = function() {
      
    };
  }

  GetSolarCtrl.$inject = ['$scope', '$rootScope', '$log'];
  angular.module('powurApp').controller('GetSolarCtrl', GetSolarCtrl);
})();
