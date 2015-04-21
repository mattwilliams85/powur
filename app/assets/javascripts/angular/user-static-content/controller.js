'use strict';

function UserStaticContentCtrl($scope) {
  $scope.redirectUnlessSignedIn();
}

UserStaticContentCtrl.$inject = ['$scope'];
sunstandControllers.controller('UserStaticContentCtrl', UserStaticContentCtrl);
