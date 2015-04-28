;(function() {
  'use strict';

  angular
    .module('powurApp')
    .controller('HomeCtrl', HomeCtrl);

  HomeCtrl.$inject = ['$scope', 'sessionService'];

  function HomeCtrl($scope, $session) {
    $scope.foo = 'great';
  }
})();
