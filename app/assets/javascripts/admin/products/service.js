;(function() {
  'use strict';

  function AdminProduct($http, $q) {
    var service = {

      /*
      * Get list of Products
      */
      list: function() {
        var dfr = $q.defer();

        $http({
          method: 'GET',
          url: '/a/products.json'
        }).success(function(res) {
          dfr.resolve(res);
        }).error(function(err) {
          console.log('エラー', err);
          dfr.reject(err);
        });

        return dfr.promise;
      },

      /*
       * Get an item
      */
      get: function(id) {
        var dfr = $q.defer();

        $http({
          method: 'GET',
          url: '/a/products/' + id + '.json'
        }).success(function(res) {
          dfr.resolve(res);
        }).error(function(err) {
          console.log('エラー', err);
          dfr.reject(err);
        });

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

  AdminProduct.$inject = ['$http', '$q'];
  angular.module('powurApp').factory('AdminProduct', AdminProduct);

})();