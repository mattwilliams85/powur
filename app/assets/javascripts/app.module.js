;
(function() {
  'use strict';

  function routeAllowed(security, session) {
    if (security === 'anon') return true;
    if (!session.loggedIn()) return false;
    return (security === 'auth' || session.admin());
  }

  function run($rootScope, $state, session) {
    $rootScope.$on('$stateChangeStart', function(event, toState) {
      var security = toState.security || 'admin';
      if (!routeAllowed(security, session)) {
        event.preventDefault();
        $state.go('home');
      }
    });
  }

  run.$inject = ['$rootScope', '$state', 'session'];

  function fetchSession() {
    var injector = angular.injector(['ng', 'app.core']);
    var session = injector.get('session');

    return session.fetch();
  }

  function bootstrap() {
    angular.element(document).ready(function() {
      angular.bootstrap(document, ['powurApp']);
    });
  }
  
  var references = [
    // shared modules
    'app.core',
    // feature areas
    'app.signin',
    'app.dashboard',
    'app.team'
  ];

  angular
    .module('powurApp', references)
    .run(run);

  fetchSession().then(bootstrap);

})();