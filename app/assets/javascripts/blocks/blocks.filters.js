;
(function() {
  'use strict';

  function dateToLocalDate() {
    return function(createdAt) {
      var date = new Date(Date.parse(createdAt)).toLocaleDateString();
      return date;
    };
  }

  function timeToLocalTime() {
    return function(createdAt) {
      var time = new Date(Date.parse(createdAt)).toLocaleTimeString();
      return time;
    };
  }

  function cleanLabel() {
    return function(label) {
      return label.split('_').join(' ');
    };
  }

  function formattedPrice() {
    return function(price) {
      return (price/100).toFixed(2);
    };
  }

  angular
    .module('blocks.filters', [])
    .filter('dateToLocalDate', dateToLocalDate)
    .filter('timeToLocalTime', timeToLocalTime)
    .filter('cleanLabel', cleanLabel)
    .filter('formattedPrice', formattedPrice);

})();
