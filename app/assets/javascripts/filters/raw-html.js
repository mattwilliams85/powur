;(function() {
  'use strict';

  function rawHtml($sce) {
    return function(val) {
      return $sce.trustAsHtml(val);
    };
  }

  rawHtml.$inject = ['$sce'];
  angular.module('powurApp').filter('rawHtml', rawHtml);
})();
