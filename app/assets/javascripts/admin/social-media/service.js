;(function() {
  'use strict';

  function AdminSocialMedia($http, $q) {
    var service = {

      /*
       * Get a social media post
      */
      get: function(id) {
        var dfr = $q.defer();

        // TODO: Make endpoints for storing social media posts
        // $http({
        //   method: 'GET',
        //   url: '/a/social_media/' + id + '.json'
        // }).success(function(res) {
        //   dfr.resolve(res);
        // }).error(function(err) {
        //   console.log('エラー', err);
        //   dfr.reject(err);
        // });

        return dfr.promise;
      },

      /*
       * Get list of social media posts
      */
      list: function() {
        var dfr = $q.defer();

        // TODO: Make endpoints for storing social media posts
        // $http({
        //   method: 'GET',
        //   url: '/a/social_media.json'
        // }).success(function(res) {
        //   dfr.resolve(res);
        // }).error(function(err) {
        //   console.log('エラー', err);
        //   dfr.reject(err);
        // });

        return dfr.promise;
      },

      /*
       * Create a social media post
      */
      create: function(data) {
        var dfr = $q.defer();
        data = data || {};

        // TODO: Make endpoints for storing social media posts
        // $http({
        //   method: 'POST',
        //   url: '/a/social_media.json',
        //   data: data
        // }).success(function(res) {
        //   dfr.resolve(res);
        // }).error(function(err) {
        //   console.log('エラー', err);
        //   dfr.reject(err);
        // });

        return dfr.promise;
      },

      /*
       * Update a social_media
      */
      update: function(data) {
        var dfr = $q.defer();
        data = data || {};

        // TODO: Make endpoints for storing social media posts
        // $http({
        //   method: 'PUT',
        //   url: '/a/social_media/' + data.id,
        //   data: data
        // }).success(function(res) {
        //   dfr.resolve(res);
        // }).error(function(err) {
        //   console.log('エラー', err);
        //   dfr.reject(err);
        // });

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

  AdminSocialMedia.$inject = ['$http', '$q'];
  angular.module('powurApp').factory('AdminSocialMedia', AdminSocialMedia);

})();
