'use strict';

function LibraryCtrl($scope, $location, Resource) {
  $scope.redirectUnlessSignedIn();
  $scope.items = [];

  $scope.setClass = function(id, prefix) {
    return prefix + '-' + id; //e.g. 'drilldown-23'
  };

  $scope.showResource = function(item) {
    var html = $('#item_' + item.properties.id).html();
    $('<div class=\'reveal-modal library-modal\' data-reveal>' + html + '<a class=\'close-reveal-modal\'>&#215;</a></div>').foundation('reveal', 'open');
    $(document).foundation();
  };

  return Resource.list().then(function(items) {
    $scope.items = items.entities;
  });

}

LibraryCtrl.$inject = ['$scope', '$location', 'Resource'];
sunstandControllers.controller('LibraryCtrl', LibraryCtrl);