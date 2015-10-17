;
(function() {
  'use strict';

  var routes = [{
    path: '/',
    component: 'home'
  }, {
    path: '/:notfound',
    component: 'notfound'
  }];

  var authRoutes = [{
    path: '/dashboard',
    component: 'dashboard'
  }];

  function AppController($router, session) {
    this.session = session;

    $router.config(routes);
    session.authCallback(function() { $router.config(authRoutes); });
  }

  AppController.$inject = ['$router', 'session'];

  angular
    .module('powurApp')
    .controller('AppController', AppController);

})();