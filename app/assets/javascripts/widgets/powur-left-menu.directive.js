;(function() {
  'use strict';

  function powurLeftMenu() {
    function link(scope, element, attrs) {
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

    var directive = {
      restrict:    'E',
      scope:       { control: '=' },
      templateUrl: 'widgets/powur-left-menu.html',
      link:        link };

    return directive;
  }

  angular
    .module('widgets.powurLeftMenu', [])
    .directive('powurLeftMenu', powurLeftMenu);

})();
