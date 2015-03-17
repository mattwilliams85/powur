'use strict';

function AdminUserGroup($http, $q) {
  var service = {

    /*
     * Get an item
    */
    get: function(id) {
      var dfr = $q.defer();

      $http({
        method: 'GET',
        url: '/a/user_groups/' + id + '.json'
      }).success(function(res) {
        dfr.resolve(res);
      }).error(function(err) {
        console.log('エラー', err);
        dfr.reject(err);
      });

      return dfr.promise;
    },

    /*
     * Get list of items
    */
    list: function() {
      var dfr = $q.defer();

      $http({
        method: 'GET',
        url: '/a/user_groups.json'
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
        url: '/a/user_groups.json',
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
     * Update an item
    */
    update: function(data) {
      var dfr = $q.defer();
      data = data || {};

      $http({
        method: 'PUT',
        url: '/a/user_groups/' + data.id,
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

AdminUserGroup.$inject = ['$http', '$q'];
sunstandServices.factory('AdminUserGroup', AdminUserGroup);