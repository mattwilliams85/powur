;(function() {
  'use strict';

  function SolarCityZipValidator($http, $q) {

    return {
      check: function(data) {
        var dfr = $q.defer();

        $http.post('/zip_validator/validate', data).success(function(res) {
          dfr.resolve(res);
        }).error(function(err) {
          console.log('エラー', err);
          dfr.reject(err);
        });

        return dfr.promise;
      }

    };
  }

  SolarCityZipValidator.$inject = ['$http', '$q'];
  angular.module('powurApp').factory('SolarCityZipValidator', SolarCityZipValidator);
})();
