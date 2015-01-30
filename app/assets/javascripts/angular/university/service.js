'use strict';

function UniversityClass($http, $q) {
  var service = {

    /*
     * Get list of items
    */
    list: function(data) {
      data = data || {};
      var dfr = $q.defer();

      $http({
        method: 'GET',
        url: '/u/university_classes',
        params: data
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
        data: data
      }).success(function(res) {
        dfr.resolve(res);
      }).error(function(err) {
        console.log('エラー', err);
        dfr.reject(err);
      });

      return dfr.promise;
    },


    /*
     * Get one item
    */
    get: function(id) {
      var dfr = $q.defer();

      $http({
        method: 'GET',
        url: '/u/university_classes/' + id
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

UniversityClass.$inject = ['$http', '$q'];
sunstandServices.factory('UniversityClass', UniversityClass);
