;(function() {
  'use strict';

  function Notification($http, $q) {
    return {
      list: function(params) {
        var dfr = $q.defer();
        params = params || {};

        $http({
          method: 'GET',
          url: '/u/notifications.json',
          params: params
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

  Notification.$inject = ['$http', '$q'];
  angular.module('powurApp').factory('Notification', Notification);
})();
