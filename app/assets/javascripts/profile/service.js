;(function() {
  'use strict';

  function UserProfile($http, $q, $cacheFactory) {
    var cache = $cacheFactory('UserProfile');
    var isProcessingRequest;

    return {
      /*
       * Sign In
       */
      signIn: function(data) {
        var dfr = $q.defer();

        $http.post('/login.json', data).success(function(res) {
          cache.put('data', res.properties);
          dfr.resolve(cache.get('data') || res);
        }).error(function(err) {
          console.log('エラー', err);
          dfr.reject(err);
        });

        return dfr.promise;
      },

      /*
       * Sign Out
       */
      signOut: function(data) {
        var dfr = $q.defer();

        $http.delete('/login.json', data).success(function() {
          cache.put('data', null);
          dfr.resolve();
        }).error(function(err) {
          console.log('エラー', err);
          dfr.reject(err);
        });

        return dfr.promise;
      },

      /*
       * Get a Profile
       */
      get: function() {
        var dfr = $q.defer();
        var userData = cache.get('data');

        if (isProcessingRequest) {
          dfr.resolve({});
        } else if (userData && userData.email) {
          dfr.resolve(userData);
        } else {
          isProcessingRequest = true;
          $http({
            method: 'GET',
            url: '/u/profile.json'
          }).success(function(res) {
            cache.put('data', res.properties);
            isProcessingRequest = false;
            dfr.resolve(cache.get('data'));
          }).error(function(err) {
            isProcessingRequest = false;
            console.log('エラー', err);
            dfr.reject(err);
          });
        }

        return dfr.promise;
      },

      /*
       * Clear cached profile
       */
      clear: function() {
        cache.put('data', null);
        return true;
      },

      /*
       * Update a Profile
       */
      update: function(data) {
        var dfr = $q.defer();

        $http.put('/u/profile.json', data, {
          xsrfHeaderName: 'X-CSRF-Token'
        }).success(function(res) {
          dfr.resolve(res);
        }).error(function(err) {
          console.log('エラー', err);
          dfr.reject(err);
        });

        return dfr.promise;
      },

      updatePassword: function(data) {
        var dfr = $q.defer();

        $http.put('/u/profile/update_password.json', data, {
          xsrfHeaderName: 'X-CSRF-Token'
        }).success(function(res) {
          dfr.resolve(res);
        }).error(function(err) {
          console.log('エラー', err);
          dfr.reject(err);
        });

        return dfr.promise;
      },

      getTeam: function(id) {
        var dfr = $q.defer();
        $http({
          method: 'GET',
          url: '/u/users/' + id + '/downline.json'
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

  UserProfile.$inject = ['$http', '$q', '$cacheFactory'];
  angular.module('powurApp').factory('UserProfile', UserProfile);
})();
