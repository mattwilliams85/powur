'use strict';

function LibraryCtrl($scope, $location, Resource) {
  $scope.redirectUnlessSignedIn();
  $scope.items = [];
  $scope.resourceTypes = [{name: 'All Media'}, {name: 'Videos', type: 'videos'}, {name: 'Documents', type: 'documents'}];
  $scope.resourceType = $scope.resourceTypes[0];

  $scope.showResource = function(item) {
    var html = $('#item_' + item.properties.id).html();
    $('<div class=\'reveal-modal library-modal\' data-reveal>' + html + '<a class=\'close-reveal-modal\'>&#215;</a></div>').foundation('reveal', 'open');
    $(document).foundation();
  };

  $scope.resourceTypeChange = function() {
    return Resource.list({type: $scope.resourceType.type }).then(function(items) {
      $scope.items = items.entities;
    });
  };

  return Resource.list().then(function(items) {
    $scope.items = items.entities;
  });

}

LibraryCtrl.$inject = ['$scope', '$location', 'Resource'];
sunstandControllers.controller('LibraryCtrl', LibraryCtrl);