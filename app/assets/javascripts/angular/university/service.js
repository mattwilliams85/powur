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
    * Enroll in a class
    */
    enroll: function(action) {
      var dfr = $q.defer();

      $http({
        method: action.method,
        url: action.href
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
    get: function(id, path) {
      var dfr = $q.defer();

      $http({
        method: 'GET',
        url: path
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
