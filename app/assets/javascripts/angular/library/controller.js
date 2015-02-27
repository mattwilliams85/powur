'use strict';

function LibraryCtrl($scope, $location) {
  $scope.redirectUnlessSignedIn();
  
  // return Library.list().then(function(items) {
  // });
  var items = ["a video", "a video", "a video", "a document", "a document", "a document"];
  
  $scope.libraryList = items;

  $scope.setClass = function(id, prefix) {
    return prefix + '-' + id; //e.g. 'drilldown-23'
  };

  $scope._drillDown = function(id) {
    var drillDownHeight = '220px';
    if ($('.thumbnail-' + id).css('margin-bottom') === drillDownHeight) {
      $('.thumbnail-' + id).animate({'margin-bottom': '0px'}, 500);
      $('.drilldown-' + id).animate({'opacity': 0}, 500);
      $('.drilldown-' + id).animate({'display': 'none'}, 500);
    } else {
      $('.thumbnail-' + id).animate({'margin-bottom': drillDownHeight}, 500);
      $('.drilldown-' + id).animate({'opacity': 1}, 500);
      $('.drilldown-' + id).css({'display': 'block'});
    }
  };
}

LibraryCtrl.$inject = ['$scope', '$location'];
sunstandControllers.controller('LibraryCtrl', LibraryCtrl);