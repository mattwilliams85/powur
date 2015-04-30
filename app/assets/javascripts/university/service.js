;(function() {
  'use strict';

  function UniversityClass($http, $q) {
    var service = {
      list: function(data) {
        data = data || {};
        var dfr = $q.defer();

        $http({
          method: 'GET',
          url: '/u/university_classes.json',
          params: data
        }).success(function(res) {
          dfr.resolve(res);
        }).error(function(err) {
          console.log('エラー', err);
          dfr.reject(err);
        });

        return dfr.promise;
      },

      get: function(id) {
        var dfr = $q.defer();

        $http({
          method: 'GET',
          url: '/u/university_classes/' + id + '.json'
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
  angular.module('powurApp').factory('UniversityClass', UniversityClass);
})();
