/// <reference path='../../typings/tsd.d.ts' />

module powur {
  'use strict';

  angular.module('powur.core', [
     // angular modules
    'ngMessages',
    'ngAnimate',
    'ngStorage',
    'ngMaterial',
    // 3rd party modules
    'ui.router',
    'ui.mask',
    'templates',
    // cross-app/util modules
    'powur.services'
  ]).config(function($mdThemingProvider) {
    $mdThemingProvider.theme('default')
      .primaryPalette('light-blue', { 'default': '500' })
      .accentPalette('teal', {'default': '400'})
  });
}
