;
(function() {
  'use strict';

  var dateToLocalDate = function() {
    return function(createdAt) {
      var date = new Date(Date.parse(createdAt)).toLocaleDateString();
      return date;
    };
  };

  var timeToLocalTime = function() {
    return function(createdAt) {
      var time = new Date(Date.parse(createdAt)).toLocaleTimeString();
      return time;
    };
  };

  var cleanStatusLabel = function() {
    return function(status) {
      return status.split('_').join(' ');
    };
  };

  angular
    .module('blocks.filters', [])
    .filter('dateToLocalDate', dateToLocalDate)
    .filter('timeToLocalTime', timeToLocalTime)
    .filter('cleanStatusLabel', cleanStatusLabel);

})();