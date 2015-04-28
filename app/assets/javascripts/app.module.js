// ;(function() {
//   'use strict';
//
//   angular
//     .module('app', [
//       'ngRoute',
//       'ngResource'
//     ])
//     .run(init);
//
//   init.$inject = ['$rootScope', 'sessionService'];
//
//   function init($rootScope, session) {
//     $rootScope.session = session.get();
//     $rootScope.loggedIn = function() {
//       var sessionKlass = $rootScope.session && $rootScope.session['class'];
//       return sessionKlass ? sessionKlass.indexOf('anonymous') === -1 : false;
//     }
//   }
// })();
