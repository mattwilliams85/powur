;(function() {
  'use strict';

  function Resource($http, $q) {
    return {
      list: function(data) {
        data = data || {};
        var dfr = $q.defer();

        $http({
          method: 'GET',
          url: '/u/resources.json',
          params: data
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

  Resource.$inject = ['$http', '$q'];
  angular.module('powurApp').factory('Resource', Resource);
})();
