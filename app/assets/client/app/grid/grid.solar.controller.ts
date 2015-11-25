/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../layout/auth.controller.ts' />

module powur {
  'use strict';

  class GridSolarController extends AuthController {
    static ControllerId = 'GridSolarController';
    static $inject = ['leadsSummary', 'leads', '$timeout'];

    get insight(): any {
      return this.leadsSummary.properties;
    }

    constructor(public leadsSummary: ISirenModel,
                public leads: ISirenModel,
                public $timeout: ng.ITimeoutService) {
      super();
    }
  }

  angular
    .module('powur.grid')
    .controller(GridSolarController.ControllerId, GridSolarController);
}
