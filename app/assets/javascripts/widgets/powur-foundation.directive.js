;(function() {
  'use strict';

  angular.module('widgets.powurFoundation', [])
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
