/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../layout/auth.controller.ts' />

module powur {
  'use strict';

  export class LandingController extends BaseController {
    static ControllerId = 'LandingController';
    static $inject = ['$stateParams', '$timeout', '$sce'];
    
    public zipCode: string = null;
    
    constructor(private $stateParams: ng.ui.IStateParamsService,
                private $timeout: ng.ITimeoutService,
                private $sce: ng.ISCEService) {
      super();

    }
    
    public checkAvailability() {
      
    }
    
    public getSavings() {
      
    }
    
    public letsGo() {
      
    }
  }

  angular
    .module('powur.landing')
    .controller(LandingController.ControllerId, LandingController);
}
