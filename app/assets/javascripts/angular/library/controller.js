'use strict';

function LibraryCtrl($scope, $location) {
  $scope.redirectUnlessSignedIn();
  
  // return Library.list().then(function(items) {
  // });
  var items = ["a video", "a video", "a video", "a document", "a document", "a document"];
  
  $scope.libraryList = items;

  $scope.doSomething = function(item) {

  };
};

LibraryCtrl.$inject = ['$scope', '$location'];
sunstandControllers.controller('LibraryCtrl', LibraryCtrl);