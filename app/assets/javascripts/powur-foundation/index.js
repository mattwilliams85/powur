;(function() {
  'use strict';

  angular.module('powurFoundation', [])
  .directive('powurFoundation', function() {
    return {
      restrict: 'A',
      link: function(scope, element, attrs) {
        // $compile($(document).foundation())(scope);
        $(document).foundation();
      }
    };
  });

})();
