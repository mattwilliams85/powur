'use strict';

function AdminPayPeriod($http, $q) {
  var service = {

    /*
     * Get a pay_period
    */
    get: function(id) {
      var dfr = $q.defer();

      $http({
        method: 'GET',
        url: '/a/pay_periods/' + id + '.json'
      }).success(function(res) {
        dfr.resolve(res);
      }).error(function(err) {
        console.log('エラー', err);
        dfr.reject(err);
      });

      return dfr.promise;
    },

    /*
     * Get list of pay_periods
    */
    list: function() {
      var dfr = $q.defer();

      $http({
        method: 'GET',
        url: '/a/pay_periods.json'
      }).success(function(res) {
        dfr.resolve(res);
      }).error(function(err) {
        console.log('エラー', err);
        dfr.reject(err);
      });

      return dfr.promise;
    },

    /*
     * Create a pay_period
    */
    create: function(data) {
      var dfr = $q.defer();
      data = data || {};

      $http({
        method: 'POST',
        url: '/a/pay_periods.json',
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
     * Update a pay_period
    */
    update: function(data) {
      var dfr = $q.defer();
      data = data || {};

      $http({
        method: 'PUT',
        url: '/a/pay_periods/' + data.id,
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

AdminPayPeriod.$inject = ['$http', '$q'];
sunstandServices.factory('AdminPayPeriod', AdminPayPeriod);