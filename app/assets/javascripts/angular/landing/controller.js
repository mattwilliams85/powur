'use strict';

function LandingCtrl($scope, $location) {
  $scope.redirectToDashboardIfSignedIn();

  $scope.signIn = function(e) {
    _formSubmit(e, $('#user_login'), '/login', 'post', function(data) {
      for (var i=0;i<=data.links.length;i++) {
        if (data.links[i].rel.indexOf('index')>=0) {
          window.location=data.links[i].href;
        }
      }
    });
  };

  this.init($scope, $location);
  this.fetch($scope);
}


LandingCtrl.prototype.init = function($scope, $location) {
  // Setting mode based on the url
  $scope.mode = 'index';
  if (/\/sign-in$/.test($location.path())) $scope.mode = 'sign-in';
};


LandingCtrl.prototype.fetch = function($scope) {
  if ($scope.mode === 'sign-in') {
    // Do something here only for sign in page
    $scope.signInPage = true;
  }
};


LandingCtrl.$inject = ['$scope', '$location', '$routeParams'];
sunstandControllers.controller('LandingCtrl', LandingCtrl);
