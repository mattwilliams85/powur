/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../layout/auth.controller.ts' />

module powur {
  'use strict';

  export class GridController extends AuthController {
    static ControllerId = 'GridController';
    // static $inject = ['$timeout'];

    // constructor(public $timeout: ng.ITimeoutService) {
    //   super();
    // }
  }

  angular
    .module('powur.grid')
    .controller(GridController.ControllerId, GridController);
}
