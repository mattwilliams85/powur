;(function() {
  'use strict';

  function Team($http, $q) {
    var isProcessingRequest;

    var service = {

      /*
       * List Team Members
       */
      list: function(params) {
        var dfr = $q.defer();
        params = params || {};

        if (isProcessingRequest) {
          dfr.resolve({});
        } else {
          isProcessingRequest = true;
          $http({
            method: 'GET',
            url: '/u/users.json',
            params: params
          }).success(function(res) {
            isProcessingRequest = false;
            dfr.resolve(res);
          }).error(function(err) {
            isProcessingRequest = false;
            console.log('エラー', err);
            dfr.reject(err);
          });
        }
        return dfr.promise;
      },

      /*
       * Get a Team Member
       */
      get: function(user) {
        var dfr = $q.defer();

        if (isProcessingRequest) {
          dfr.resolve({});
        } else {
          isProcessingRequest = true;
          $http({
            method: 'GET',
            url: '/u/users/' + userId + '.json'
          }).success(function(res) {
            isProcessingRequest = false;
            dfr.resolve(res);
          }).error(function(err) {
            isProcessingRequest = false;
            console.log('エラー', err);
            dfr.reject(err);
          });
        }

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

  Team.$inject = ['$http', '$q'];
  angular.module('powurApp').factory('Team', Team);

})();
