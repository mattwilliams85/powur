;
(function() {
  'use strict';

  function Action() {
  }

  Action.prototype.field = function(name) {
    return this.fields.filter(function(obj) {
      return obj.name === name;
    })[0];
  };

  Action.prototype.submitCallback = function(data, status, headers, cfg) {
    if (!angular.isObject(data)) return;

    var error = data.error;
    if (error) {
      if (error.type === 'input') {
        var field = this.field(error.input);
        if (field) field.error = error.message;
      } else {
        this.error = error.message;
      }
      if (this.callbacks)
        this.callbacks.error.forEach(function(callback) {
          callback.call(this, data, status, headers, cfg);
        });
    } else {
      if (this.callbacks)
        this.callbacks.success.forEach(function(callback) {
          callback.call(this, data, status, headers, cfg);
        });
    }
  };

  Action.prototype.success = function(callback) {
    if (!this.callbacks) this.callbacks = { success: [], error: [] };
    this.callbacks.success.push(callback);
  };

  Action.prototype.error = function(callback) {
    if (!this.callbacks) this.callbacks = { success: [], error: [] };
    this.callbacks.error.push(callback);
  };

  Action.prototype.clearErrors = function() {
    delete this.error;
    angular.forEach(this.fields, function(field) {
      delete field.error;
    });
  };

  Action.prototype.submit = function(cfg) {
    this.clearErrors();
    var injector = angular.element(document).injector();
    var $http = injector.get('$http');
    var postData = {};

    angular.forEach(this.fields, function(field) {
      postData[field.name] = field.value;
    });
    var defaultCfg = {
      method: this.method,
      url:    this.href
    };
    var dataKey = this.method === 'GET' ? 'params' : 'data';
    defaultCfg[dataKey] = postData;
    var req = angular.extend({}, defaultCfg, cfg);

    return $http(req).success(this.submitCallback.bind(this));
  };

  function decorateAction(action) {
    return angular.extend(action, Action.prototype);
  }

  function decorateActions(data) {
    var actions = data.actions;
    data.actions = {};

    if (actions && actions.length) {
      angular.forEach(actions, function(value) {
        data.actions[value.name] = decorateAction(value);
      });
    }

    data.hasAction = function(value) {
      return data.actions[value];
    };
  }

  function EntityRef() {}

  EntityRef.prototype.get = function() {
    var injector = angular.element(document.body).injector();
    var $http = injector.get('$http');

    return $http.get(this.href);
  };

  function decorateEntity(entity) {
    return entity.href ? angular.extend(entity, EntityRef.prototype) : decorate(entity);
  }

  function decorateEntities(data) {
    var entities = data.entities;
    data.entities = {};

    if (entities && entities.length) {
      angular.forEach(entities, function(value) {
        if (value.rel) data.entities[value.rel[0]] = decorateEntity(value);
      });
    }

    return data;
  }

  function decorateEntityList(data) {
    for (var i = 0, j = data.entities.length; i !== j; i++) {
      data.entities[i] = decorateEntity(data.entities[i]);
    }

    return data;
  }

  function decorate(data) {
    data.hasClass = function(name) {
      return this['class'].indexOf(name) !== -1;
    };
    decorateActions(data);
    return data.hasClass('list') ? decorateEntityList(data) : decorateEntities(data);
  }

  function formatResponse(response) {
    var data = response.data;
    if (angular.isObject(data) && data['class'])
      decorate(data);

    return response;
  }

  var siren = {
    decorate: decorate,
    interceptor: function() {
      return {
        response: formatResponse
      };
    }
  };

  angular
    .module('blocks.siren', [])
    .constant('siren', siren);

})();
