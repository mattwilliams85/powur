;
(function() {
  'use strict';

  var req = {
    method:  'GET',
    url:     '/',
    headers: { 'X-Requested-With' : 'XMLHttpRequest' } };

  function Session() {
    this.authedCallbacks = [];
  }

  Session.prototype.loggedIn = function() {
    return this.data && this.data.hasClass('user');
  };

  Session.prototype.admin = function() {
    return this.loggedIn() && this.data.properties.admin == true;
  };

  Session.prototype.runAuthedCallbacks = function() {
    while (this.authedCallbacks.length) {
      this.authedCallbacks.shift().call();
    }
  };

  Session.prototype.fetch = function() {
    var injector = angular.injector(['ng', 'blocks.siren']);
    var $http = injector.get('$http');
    var siren = injector.get('siren');

    var success = (function(data) {
      this.refresh(siren.decorate(data));
    }).bind(this);

    return $http(req).success(success);
  };

  Session.prototype.refresh = function(data) {
    this.data = data;
    if (this.loggedIn()) this.runAuthedCallbacks();
  };

  Session.prototype.authCallback = function(callback) {
    this.loggedIn() ? callback.call() : this.authedCallbacks.push(callback);
  };

  Session.prototype.logout = function(callback) {
    this.data.actions.logout.submit().then(callback);
  }

  angular
    .module('app.core')
    .constant('session', new Session());

})();