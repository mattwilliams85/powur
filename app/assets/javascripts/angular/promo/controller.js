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
        $scope.gotoAnchor('on_slider_move');
      }, 200);
    }
  });

  $scope.minTime = new Date(2000, 1, 1, 0, 0, 0, 0).valueOf();
  // Max time is 3 minutes
  $scope.maxTime = new Date(2000, 1, 1, 0, 0, 0, 0).valueOf() + (1000 * 60 * 3);
  $scope.solarTime = $scope.maxTime;
  $scope.solarTimerSeconds = '00';
  $scope.solarTimerMinutes = '03';
  $scope.solarTimerHours = '00';
  $scope.solarTimerPeople = 0;
  var timeStrings;
  $scope.solarTimerStop = $interval(function() {
    $scope.solarTime -= 1000;
    timeStrings = new Date($scope.solarTime).toTimeString().split(':');
    $scope.solarTimerHours = timeStrings[0];
    $scope.solarTimerMinutes = timeStrings[1];
    $scope.solarTimerSeconds = /^[\d]{2}/.exec(timeStrings[2])[0];
    if ($scope.solarTime === $scope.minTime) {
      $scope.solarTimerPeople += 1;
      $scope.solarTime = $scope.maxTime;
    }
  }, 1000);


  // Setting mode based on the url
  $scope.mode = 'create-wealth';
  if (/\/create-energy$/.test($location.path())) $scope.mode = 'create-energy';
};


PromoCtrl.$inject = ['$scope', '$location', '$timeout', '$interval', '$anchorScroll'];
sunstandControllers.controller('PromoCtrl', PromoCtrl);
