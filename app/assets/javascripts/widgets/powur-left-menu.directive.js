;(function() {
  'use strict';

  angular.module('powurLeftMenu', []).directive('powurLeftMenu', function() {
    return {
      restrict: 'E',
      scope: {
        control: '='
      },
      templateUrl: 'widgets/powur-left-menu.html',
      link: function (scope, element, attrs) {
        scope.internalControl = scope.control || {};
        scope.internalControl.isActive = false;
        scope.internalControl.hide = function() {
          scope.internalControl.isActive = false;
          $('#pp-nav').fadeIn();
        };
        scope.internalControl.show = function() {
          scope.internalControl.isActive = true;
          $('#pp-nav').fadeIn();
        };
      }
    };
  });

})();
