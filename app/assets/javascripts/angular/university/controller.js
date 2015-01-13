'use strict';

function UniversityCtrl($scope, $location, UniversityClass) {
  $scope.redirectUnlessSignedIn();

  this.init($scope, $location);
  this.fetch($scope, UniversityClass);
}


UniversityCtrl.prototype.init = function($scope, $location) {
  // Setting mode based on the url
  $scope.mode = 'index';
  if (/\/[\d]+$/.test($location.path())) $scope.mode = 'else';
};


UniversityCtrl.prototype.fetch = function($scope, UniversityClass) {
  if ($scope.mode === 'index') {
    return UniversityClass.list().then(function(items) {
      $scope.universityClasses = items;
    });
  }
};


UniversityCtrl.$inject = ['$scope', '$location', 'UniversityClass'];
sunstandControllers.controller('UniversityCtrl', UniversityCtrl);
