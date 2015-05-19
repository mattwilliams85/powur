;(function() {
  'use strict';

  function powurLeftMenu() {
    var directive = {
      link: link,
      templateUrl: 'widgets/powur-left-menu.html',
      restrict: 'E'
    };
    return directive;

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
  }

  angular
    .module('app.widgets')
    .directive('powurLeftMenu', powurLeftMenu);

})();
