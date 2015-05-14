;(function() {
  'use strict';

  function CommonService($http, $q) {
    return {
      execute: function(action, data) {
        var dfr = $q.defer();
        data = data || {};

        $http({
          method: action.method || 'GET',
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
  }

  CommonService.$inject = ['$http', '$q'];
  angular.module('powurApp').factory('CommonService', CommonService);
})();
