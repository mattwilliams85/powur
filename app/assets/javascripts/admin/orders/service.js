;(function() {
  'use strict';

  function Order($http, $q) {
    var service = {
      get: function(id) {
        var dfr = $q.defer();

        $http({
          method: 'GET',
          url: '/a/orders/' + id + '.json'
        }).success(function(res) {
          dfr.resolve(res);
        }).error(function(err) {
          console.log('エラー', err);
          dfr.reject(err);
        });

        return dfr.promise;
      },

      list: function() {
        var dfr = $q.defer();

        $http({
          method: 'GET',
          url: '/a/orders.json'
        }).success(function(res) {
          dfr.resolve(res);
        }).error(function(err) {
          console.log('エラー', err);
          dfr.reject(err);
        });

        return dfr.promise;
      },

      create: function(data) {
        var dfr = $q.defer();
        data = data || {};

        $http({
          method: 'POST',
          url: '/a/orders.json',
          data: data
        }).success(function(res) {
          dfr.resolve(res);
        }).error(function(err) {
          console.log('エラー', err);
          dfr.reject(err);
        });

        return dfr.promise;
      },

      update: function(data) {
        var dfr = $q.defer();
        data = data || {};

        $http({
          method: 'PUT',
          url: '/a/orders/' + data.id,
          data: data
        }).success(function(res) {
          dfr.resolve(res);
        }).error(function(err) {
          console.log('エラー', err);
          dfr.reject(err);
        });

        return dfr.promise;
      },

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

  Order.$inject = ['$http', '$q'];
  angular.module('powurApp').factory('Order', Order);

})();
