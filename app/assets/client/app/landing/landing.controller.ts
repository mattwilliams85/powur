/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../layout/auth.controller.ts' />

module powur {
  'use strict';

  export class LandingController extends BaseController {
    static ControllerId = 'LandingController';
    static $inject = ['$stateParams', '$timeout', '$sce'];
    
    //step 1
    public zipCode: string = null;
    
    //step 2
    public monthly: number = 95;
    public info: any;
    
    constructor(private $stateParams: ng.ui.IStateParamsService,
                private $timeout: ng.ITimeoutService,
                private $sce: ng.ISCEService) {
      super();
      
      //step 2
      this.info = {
        firstName: null,
        lastName: null,
        address: null,
        city: null,
        state: null,
        zip: null,
        phone: null,
        email: null,
      }
    }
    //step 1
    public checkAvailability() {
      this.state.go('landing-step2');
    }
    
    //step 1
    public getSavings() {
      this.state.go('landing-step2');
    }
    
    //step 1
    public letsGo() {
      this.state.go('landing-step2');
    }
    
    //step 2
    public go() {
      this.state.go('landing-thanks');
    }
  }

  angular
    .module('powur.landing')
    .controller(LandingController.ControllerId, LandingController);
}
