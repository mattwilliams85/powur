;
(function() {
  'use strict';

  angular
    .module('blocks.filters', [])

    .filter('dateToLocalDate', function() {
      return function(createdAt) {
        var date = new Date(Date.parse(createdAt)).toLocaleDateString();
        return date;
      };
    })
    .filter('timeToLocalTime', function() {
      return function(createdAt) {
        var time = new Date(Date.parse(createdAt)).toLocaleTimeString();
        return time;
      };
    });

})();