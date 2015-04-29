;(function() {
  'use strict';

  function AdminQuote($http, $q) {
    var service = {

      /*
       * Get a quote
      */
      get: function(id) {
        var dfr = $q.defer();

        $http({
          method: 'GET',
          url: '/a/quotes/' + id + '.json'
        }).success(function(res) {
          dfr.resolve(res);
        }).error(function(err) {
          console.log('エラー', err);
          dfr.reject(err);
        });

        return dfr.promise;
      },

      /*
       * Get list of quotes
      */
      list: function() {
        var dfr = $q.defer();

        $http({
          method: 'GET',
          url: '/a/quotes.json'
        }).success(function(res) {
          dfr.resolve(res);
        }).error(function(err) {
          console.log('エラー', err);
          dfr.reject(err);
        });

        return dfr.promise;
      },

      /*
       * Create a quote
      */
      create: function(data) {
        var dfr = $q.defer();
        data = data || {};

        $http({
          method: 'POST',
          url: '/a/quotes.json',
          data: data
        }).success(function(res) {
          dfr.resolve(res);
        }).error(function(err) {
          console.log('エラー', err);
          dfr.reject(err);
        });

        return dfr.promise;
      },

      /*
       * Update a quote
      */
      update: function(data) {
        var dfr = $q.defer();
        data = data || {};

        $http({
          method: 'PUT',
          url: '/a/quotes/' + data.id,
          data: data
        }).success(function(res) {
          dfr.resolve(res);
        }).error(function(err) {
          console.log('エラー', err);
          dfr.reject(err);
        });

        return dfr.promise;
      },

      /*
       * Execute an action
      */
      execute: function(action, data) {
        var dfr = $q.defer();
        data = data || {};
        $http({
          method: action.method,
          url: action.href,
          data: data,
          type: action.type
        }).success(function(res) {
          dfr.resolve(res);
        }).error(function(err) {
          console.log('エラー', err);
          dfr.reject(err);
        });

        return dfr.promise;
      }
    };

    return service;
  }

  AdminQuote.$inject = ['$http', '$q'];
  angular.module('powurApp').factory('AdminQuote', AdminQuote);

})();
