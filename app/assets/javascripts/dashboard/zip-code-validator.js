;(function() {
  'use strict';

  function ZipCodeValidator($http, $q) {
    return {
      check: function(zipCode) {
        var dfr = $q.defer();
        zipCode = zipCode || {};

        $http({
          method: 'GET',
          url: 'https://api.solarcity.com/solarbid/api/warehouses/zip/' + zipCode,
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

  ZipCodeValidator.$inject = ['$http', '$q'];
  angular.module('powurApp').factory('ZipCodeValidator', ZipCodeValidator);
})();
