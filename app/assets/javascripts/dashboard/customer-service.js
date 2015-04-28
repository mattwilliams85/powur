'use strict';

function Customer($http, $q, $cacheFactory) {
  var cache = $cacheFactory('Customer');
  var isProcessingRequest;

  var service = {

    /*
     * List Proposals 
     */
    list: function() {
      var dfr = $q.defer();

      if (isProcessingRequest) {
        dfr.resolve({});
      } else {
        isProcessingRequest = true;
        $http({
          method: 'GET',
          url: '/u/quotes.json'
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

    /*
     * Get a Proposal
     */
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

Customer.$inject = ['$http', '$q', '$cacheFactory'];
sunstandServices.factory('Customer', Customer);
