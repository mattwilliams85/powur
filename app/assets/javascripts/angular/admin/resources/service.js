'use strict';

function AdminResource($http, $q) {
  var service = {

    /*
     * Get list of items
    */
    list: function(data) {
      data = data || {};
      var dfr = $q.defer();

      $http({
        method: 'GET',
        url: '/u/resources',
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

  return service;
}

AdminResource.$inject = ['$http', '$q'];
sunstandServices.factory('AdminResource', AdminResource);
