'use strict';

function CurrentUser($http, $q, $cacheFactory) {
  var service = {

    /*
    * Get user data
    */
    get: function() {
      var dfr = $q.defer();
      var cache = $cacheFactory('CurrentUser');
      var userData = cache.get('data');

      if (userData && userData.email) {
        dfr.resolve(userData);
      } else {
        $http({
          method: 'GET',
          url: '/u/profile.json'
        }).success(function(res) {
          cache.put('data', res.properties);
          dfr.resolve(cache.get('data'));
        }).error(function(err) {
          console.log('エラー', err);
          dfr.reject(err);
        });
      }

      return dfr.promise;
    },

    /*
    * Clear user data
    */
    clear: function() {
      $cacheFactory('CurrentUser').put('data', {});
      return true;
    }
  };

  return service;
}

CurrentUser.$inject = ['$http', '$q', '$cacheFactory'];
sunstandServices.factory('CurrentUser', CurrentUser);
