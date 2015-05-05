;(function() {
  'use strict';

  function AdminResource($http, $q) {
    var service = {

      /*
       * Get list of items
      */
      list: function(data) {
        data = data || {};
        var dfr = $q.defer();

        $http({
          method: 'GET',
          url: '/a/resources.json',
          params: data
        }).success(function(res) {
          dfr.resolve(res);
        }).error(function(err) {
          console.log('エラー', err);
          dfr.reject(err);
        });

        return dfr.promise;
      },

      /*
       * Create an item
      */
      create: function(data) {
        var dfr = $q.defer();
        data = data || {};

        $http({
          method: 'POST',
          url: '/a/resources.json',
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
       * Get an item
      */
      get: function(id) {
        var dfr = $q.defer();

        $http({
          method: 'GET',
          url: '/a/resources/' + id + '.json'
        }).success(function(res) {
          dfr.resolve(res);
        }).error(function(err) {
          console.log('エラー', err);
          dfr.reject(err);
        });

        return dfr.promise;
      },

      /*
       * Update an item
      */
      update: function(data) {
        var dfr = $q.defer();
        data = data || {};

        $http({
          method: 'PUT',
          url: '/a/resources/' + data.id + '.json',
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
          data: data
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

  AdminResource.$inject = ['$http', '$q'];
  angular.module('powurApp').factory('AdminResource', AdminResource);

})();
