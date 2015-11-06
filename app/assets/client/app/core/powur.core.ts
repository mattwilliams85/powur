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
    'templates',
    // cross-app/util modules
    'powur.services'
  ]);
}
