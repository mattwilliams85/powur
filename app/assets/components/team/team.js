;
(function() {
  'use strict';

  function TeamController(session, users) {
    this.session = session;
    this.users = users.data;

    this.action = this.users.actions.index

    this.users.actions.index.success(this.afterIndex.bind(this));
  }

  TeamController.prototype.afterIndex = function(data) {
    this.users = data;
    this.action = this.users.actions.index;
  };

  TeamController.$inject = ['session', 'users'];

  angular
    .module('app.team', [])
    .controller('TeamController', TeamController);

})();
