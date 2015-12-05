;(function() {
  'use strict';

  function GetSolarCtrl($scope, $rootScope, $log) {
    $log.debug('GetSolarCtrl');
  }

  GetSolarCtrl.$inject = ['$scope', '$rootScope', '$log'];
  angular.module('powurApp').controller('GetSolarCtrl', GetSolarCtrl);
})();
