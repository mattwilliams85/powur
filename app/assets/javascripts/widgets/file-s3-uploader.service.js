;(function() {
  'use strict';

  function S3UploaderService($http, $q) {
    return {
      /*
       * Get S3 Upload Credientials
       */
      getCredentials: function(mimetype, mode) {
        var dfr = $q.defer();

        $http({
          method: 'GET',
          url: '/u/uploader_config.json',
          params: {
            mimetype: mimetype,
            mode: mode
          }
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

  S3UploaderService.$inject = ['$http', '$q'];
  angular.module('powurApp').factory('S3UploaderService', S3UploaderService);
})();
