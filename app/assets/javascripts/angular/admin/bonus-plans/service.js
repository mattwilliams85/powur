'use strict';

function AdminBonusPlan($http, $q) {
  var service = {

    /*
    * Get list of Bonus Plans
    */
    list: function() {
      var dfr = $q.defer();

      $http({
        method: 'GET',
        url: '/a/bonus_plans.json'
      }).success(function(res) {
        dfr.resolve(res);
      }).error(function(err) {
        console.log('エラー', err);
        dfr.reject(err);
      });

      return dfr.promise;
    },

    /*
     * Get a Bonus Plan
    */
    get: function(id) {
      var dfr = $q.defer();

      $http({
        method: 'GET',
        url: '/a/bonus_plans/' + id + '.json'
      }).success(function(res) {
        dfr.resolve(res);
      }).error(function(err) {
        console.log('エラー', err);
        dfr.reject(err);
      });

      return dfr.promise;
    },
  };

  return service;
}

AdminBonusPlan.$inject = ['$http', '$q'];
sunstandServices.factory('AdminBonusPlan', AdminBonusPlan);