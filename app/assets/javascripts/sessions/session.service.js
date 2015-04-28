// ;(function() {
//   'use strict';
//
//   angular
//     .module('powurApp')
//     .factory('sessionService', session);
//
//   session.$inject = ['$resource', '$http', '$window'];
//
//   function session($resource, $http, $window) {
//     var addActions = function(data) {
//       if (angular.isObject(data) && data['actions']) {
//         angular.forEach(data['actions'], function(value) {
//           data[value['name']] = function(opts) {
//
//             console.log(value['href']);
//           }
//         });
//         console.log('actions!')
//       }
//       return data;
//     }
//
//     return $resource('/', {}, {
//       get: {
//         method:            'GET',
//         headers:           { 'X-Requested-With' : 'XMLHttpRequest' },
//         transformResponse: $http.defaults.transformResponse.concat(addActions) }
//     });
//   }
//
//
// })();
