;(function() {
  'use strict';

  function Bonus($http, $q) {
    var service = {
      list: function(bonusPlanId) {
        var dfr = $q.defer();
        $http({
          method: 'GET',
          url: '/a/bonus_plans/' + bonusPlanId + '/bonuses.json',
          type: 'application/json'
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
          url: '/a/bonuses/' + id + '.json',
          type: 'application/json'
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
          type: action.type,
          data: data
        }).success(function(res) {
          dfr.resolve(res);
        }).error(function(err) {
          console.log('エラー', err);
          dfr.reject(err);
        });

        return dfr.promise;
      },

      listFromHref: function(href) {
        var dfr = $q.defer();
        $http({
          method: 'GET',
          url: href + '.json',
          type: 'application/json'
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

  Bonus.$inject = ['$http', '$q'];
  angular.module('powurApp').factory('Bonus', Bonus);
})();
