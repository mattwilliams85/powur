'use strict';

function Notification($http, $q) {
  var isProcessingRequest;

  var service = {

    /*
     * List Notifications 
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
          url: '/u/notifications.json',
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
    }
  };

  return service;
}

Notification.$inject = ['$http', '$q'];
angular.module('powurApp').factory('Notification', Notification);
