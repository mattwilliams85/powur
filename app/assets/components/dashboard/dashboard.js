;
(function() {
  'use strict';

  function DashboardController(session, $state) {
    this.header = 'Dashboard';
    this.session = session;
    this.$state = $state;
  }

  DashboardController.prototype.logout = function() {
    this.session.logout((function() {
      this.$state.go('home');
    }).bind(this));
  }

  DashboardController.$inject = ['session', '$state'];

  function config($stateProvider, session) {
    $stateProvider
      .state('dashboard', {
        url: '/dashboard',
        templateUrl: '/assets/dashboard/index.html',
        controller: 'DashboardController as dashboard',
        abstract: true
      })
      .state('dashboard.index', {
        url: '',
        security: 'auth',
        views: {
          team: {
            templateUrl: '/assets/team/index.html',
            security: 'auth',
            controller: 'TeamController as team',
            resolve: {
              users: function(session) {
                return session.data.entities['user-users'].get();
              }
            }
          },
          goals: {
            templateUrl: '/assets/goals/index.html',
            security: 'auth'
      }
        }
      });
  }

  config.$inject = ['$stateProvider', 'session'];

  angular
    .module('app.dashboard', [])
    .config(config)
    .controller('DashboardController', DashboardController)

})();
