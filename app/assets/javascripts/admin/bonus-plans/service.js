;(function() {
  'use strict';

  function BonusPlan($http, $q) {
    var service = {
      list: function() {
        var dfr = $q.defer();

        $http({
          method: 'GET',
          url: '/a/bonus_plans.json'
        }).success(function(res) {
          dfr.resolve(res);
        }).error(function(err) {
          console.log('エラー', err);
          dfr.reject(err);
        });

        return dfr.promise;
      },

      get: function(id) {
        var dfr = $q.defer();

        $http({
          method: 'GET',
          url: '/a/bonus_plans/' + id + '.json'
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

  BonusPlan.$inject = ['$http', '$q'];
  angular.module('powurApp').factory('BonusPlan', BonusPlan);
})();
