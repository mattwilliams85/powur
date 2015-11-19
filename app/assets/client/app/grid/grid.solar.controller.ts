/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../layout/auth.controller.ts' />

module powur {
  'use strict';

  class GridSolarController extends AuthController {
    static ControllerId = 'GridSolarController';
    static $inject = ['$timeout'];

    constructor(public $timeout: ng.ITimeoutService) {
      super();
    }
  }

  angular
    .module('powur.grid')
    .controller(GridSolarController.ControllerId, GridSolarController);
}
