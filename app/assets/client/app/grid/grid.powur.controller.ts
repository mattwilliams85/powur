/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../layout/auth.controller.ts' />

module powur {
  'use strict';

  class GridPowurController extends AuthController {
    static ControllerId = 'GridPowurController';
    static $inject = ['$timeout'];

    constructor(public $timeout: ng.ITimeoutService) {
      super();
    }
  }

  angular
    .module('powur.grid')
    .controller(GridPowurController.ControllerId, GridPowurController);
}
