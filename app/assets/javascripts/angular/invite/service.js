'use strict';

function Invite($http, $q) {

  var service = {

    /*
     * Validate invite code
    */
    validate: function(code) {
      var dfr = $q.defer();

      $http.post('/invite/validate.json', {
        code: code,
      }, {
        xsrfHeaderName: 'X-CSRF-Token'
      }).success(function(res) {
        dfr.resolve(res);
      }).error(function(err) {
        console.log('エラー', err);
        dfr.reject(err);
      });

      return dfr.promise;
    },

    /*
     * Sign Up using invitation
    */
    signUp: function(code, userData, path) {
      var dfr = $q.defer();
      userData.code = code;

      $http.put(path, userData, {
        xsrfHeaderName: 'X-CSRF-Token'
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

Invite.$inject = ['$http', '$q'];
sunstandServices.factory('Invite', Invite);
