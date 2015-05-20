;(function() {
  'use strict';

  function powurFoundation() {
    function link() {
      $(document).foundation();
    }

    return {
      restrict: 'A',
      link: link
    };
  }

  angular
    .module('widgets.powurFoundation', [])
    .directive('powurFoundation', powurFoundation);

})();
