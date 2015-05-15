;(function() {
  'use strict';

  function Proposal($http, $q, $cacheFactory) {
    var cache = $cacheFactory('Proposal');
    var isProcessingRequest;

    return {
      list: function(params) {
        var dfr = $q.defer();
        params = params || {};

        if (isProcessingRequest) {
          dfr.resolve({});
        } else {
          isProcessingRequest = true;
          $http({
            method: 'GET',
            url: '/u/quotes.json',
            params: params
          }).success(function(res) {
            cache.put('data', res);
            isProcessingRequest = false;
            dfr.resolve(cache.get('data'));
          }).error(function(err) {
            isProcessingRequest = false;
            console.log('エラー', err);
            dfr.reject(err);
          });
        }
        return dfr.promise;
      },

      get: function(proposalId) {
        var dfr = $q.defer();

        if (isProcessingRequest) {
          dfr.resolve({});
        } else {
          isProcessingRequest = true;
          $http({
            method: 'GET',
            url: '/u/quotes/' + proposalId + '.json'
          }).success(function(res) {
            cache.put('data', res);
            isProcessingRequest = false;
            dfr.resolve(cache.get('data'));
          }).error(function(err) {
            isProcessingRequest = false;
            console.log('エラー', err);
            dfr.reject(err);
          });
        }

        return dfr.promise;
      }
    };
  }

  Proposal.$inject = ['$http', '$q', '$cacheFactory'];
  angular.module('powurApp').factory('Proposal', Proposal);
})();
