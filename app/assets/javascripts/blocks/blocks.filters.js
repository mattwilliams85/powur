;
(function() {
  'use strict';

  function dateToLocalDate() {
    return function(createdAt) {
      if (createdAt === null || typeof createdAt === 'undefined') {
        return 'not available';
      }
      var date = new Date(Date.parse(createdAt)).toLocaleDateString();
      return date;
    };
  }

  function dateSuffix() {
    var suffixes = ["th", "st", "nd", "rd"];
    var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return function(input) {
      if (!input) return;
      var date = new Date(input);
      var dtfilter = months[date.getUTCMonth()] + ' ' + date.getUTCDate();
      var day = parseInt(dtfilter.slice(-2));
      var relevantDigits = (day < 30) ? day % 20 : day % 30;
      var suffix = (relevantDigits <= 3) ? suffixes[relevantDigits] : suffixes[0];
      return dtfilter + suffix + ' ' + date.getUTCFullYear();
    };
  }

  function timeToLocalTime() {
    return function(createdAt) {
      if (createdAt === null || typeof createdAt === 'undefined') {
        return 'not available';
      }
      var time = new Date(Date.parse(createdAt)).toLocaleTimeString();
      return time;
    };
  }

  function dateTimeToLocal() {
    return function(createdAt) {
      if (createdAt === null || typeof createdAt === 'undefined') {
        return 'not available';
      }
      var date = new Date(Date.parse(createdAt)).toLocaleDateString();
      var time = new Date(Date.parse(createdAt)).toLocaleTimeString();
      return date + ' ' + time;
    };
  }

  function cleanLabel() {
    return function(label) {
      if (typeof label === 'undefined') {
        return;
      }
      return label.split('_').join(' ');
    };
  }

  function titleCase() {
    return function(input) {
      input = ( input === undefined || input === null ) ? '' : input;
      var words = [];
      input = input.toString().toLowerCase().split('_');

      for (var i = 0; i < input.length; i++) {
        words.push(input[i].replace(/\w\S*/g, function(txt) {
          return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();
        }))
      };
      return words.join('');
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
    .filter('dateTimeToLocal', dateTimeToLocal)
    .filter('cleanLabel', cleanLabel)
    .filter('titleCase', titleCase)
    .filter('formattedPrice', formattedPrice)
    .filter('dateSuffix', dateSuffix);
})();
