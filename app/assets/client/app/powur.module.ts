/// <reference path='../typings/tsd.d.ts' />

module powur {
  'use strict';

  angular.module('powur', [
    'powur.core',
    'powur.components',

    // feature modules
    'powur.layout',
    'powur.login',
    'powur.invite',
    'powur.join',
    'powur.events'
  ]);
}