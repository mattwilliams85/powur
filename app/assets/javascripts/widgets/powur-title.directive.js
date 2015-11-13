;(function() {
  'use strict';

  function powurTitle($rootScope, $timeout, $location) {
    function link(scope, element) {

       function capitalizeFirstLetter(string) {
           return string.charAt(0).toUpperCase() + string.slice(1);
       }

       var listener = function(event) {
        var title = $location.$$url.substring(1);
        title = 'Powur ' + capitalizeFirstLetter(title);
        
        $timeout(function() {
          element.text(title);
        }, 0, false);
      };
      $rootScope.$on('$routeChangeSuccess', listener);
    }

    return {
      restrict: 'A',
      link: link
    };
  }

  powurTitle.$inject = ['$rootScope', '$timeout', '$location'];

  angular
    .module('widgets.powurTitle', [])
    .directive('powurTitle', powurTitle);

})();
