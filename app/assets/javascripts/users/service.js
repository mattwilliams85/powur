;(function() {
  'use strict';

  function User($http, $q) {
    return {
      list: function(params) {
        var dfr = $q.defer();
        params = params || {};

        $http({
          method: 'GET',
          url: '/u/users.json',
          params: params
        }).success(function(res) {
          dfr.resolve(res);
        }).error(function(err) {
          console.log('エラー', err);
          dfr.reject(err);
        });

        return dfr.promise;
      },

      get: function(userId) {
        var dfr = $q.defer();

        $http({
          method: 'GET',
          url: '/u/users/' + userId + '.json'
        }).success(function(res) {
          dfr.resolve(res);
        }).error(function(err) {
          console.log('エラー', err);
          dfr.reject(err);
        });

        return dfr.promise;
      }
    };
  }

  User.$inject = ['$http', '$q'];
  angular.module('powurApp').factory('User', User);
})();
