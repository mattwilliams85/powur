;
(function() {
  'use strict';

  function SigninController(session, $state) {
    this.session = session;
    this.$state = $state;

    if (this.session.loggedIn()) return;
    this.action = this.session.data.actions.create;
    this.action.success(this.afterSignIn.bind(this));
  }

  SigninController.prototype.afterSignIn = function(data) {
    this.session.refresh(data);
    this.$state.go('dashboard.index');
  };

  SigninController.$inject = ['session', '$state'];

  function config($stateProvider, session) {
    $stateProvider
      .state('signin', {
        url: '/signin',
        templateUrl: '/assets/signin/index.html',
        controller: 'SigninController as signin',
        security: 'anon'
      });
  }

  config.$inject = ['$stateProvider', 'session'];

  angular
    .module('app.signin', [])
    .config(config)
    .controller('SigninController', SigninController);

})();