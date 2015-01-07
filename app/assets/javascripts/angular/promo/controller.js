'use strict';

function PromoCtrl($scope, $location, $timeout, $interval, $anchorScroll) {
  $scope.redirectToDashboardIfSignedIn();

  $anchorScroll();

  $scope.isMenuActive = false;
  $scope.hideMenuClick = function() {
    $scope.isMenuActive = false;
  };
  $scope.showMenuClick = function() {
    $scope.isMenuActive = true;
  };

  this.init($scope, $location, $timeout, $interval);
}


PromoCtrl.prototype.init = function($scope, $location, $timeout, $interval) {
  $timeout(function() {
    $scope.invertHeaderColor();
  }, 2000);

  $scope.$watch('slider', function(newValue) {
    if (newValue === '1') {
      $timeout(function() {
        $scope.gotoAnchor('case_for_solar');
      }, 200);
    }
  });

  $scope.pageOpenTime = new Date(2000, 1, 1, 0, 0, 0, 0).valueOf();
  $scope.solarTime = $scope.pageOpenTime;
  $scope.solarTimerSeconds = '00';
  $scope.solarTimerMinutes = '00';
  $scope.solarTimerHours = '00';
  $scope.solarTimerPeople = 0;
  var timeStrings;
  $scope.solarTimerStop = $interval(function() {
    $scope.solarTime += 1000;
    timeStrings = new Date($scope.solarTime).toTimeString().split(':');
    $scope.solarTimerHours = timeStrings[0];
    $scope.solarTimerMinutes = timeStrings[1];
    $scope.solarTimerSeconds = /^[\d]{2}/.exec(timeStrings[2])[0];
    $scope.solarTimerPeople = Math.floor(($scope.solarTime - $scope.pageOpenTime)/1000/30);
  }, 1000);

  // Setting mode based on the url
  $scope.mode = 'create-wealth';
  if (/\/create-energy$/.test($location.path())) $scope.mode = 'create-energy';
};


PromoCtrl.$inject = ['$scope', '$location', '$timeout', '$interval', '$anchorScroll'];
sunstandControllers.controller('PromoCtrl', PromoCtrl);
