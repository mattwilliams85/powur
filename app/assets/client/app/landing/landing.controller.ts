/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../layout/auth.controller.ts' />

module powur {
  'use strict';

  export class LandingController extends BaseController {
    static ControllerId = 'LandingController';
    static $inject = ['$stateParams', 'rep'];
    
    get validateZipAction(): Action {
      return this.rep.action('validate_zip');
    }
    
    get zip(): Field {
      return this.validateZipAction.field('zip');
    }
    
    get leadAction(): Action {
      return this.rep.action('submit_lead');
    }

    get params(): any {
      return this.$stateParams;
    }
    
    constructor(private $stateParams: ng.ui.IStateParamsService,
                private rep: ISirenModel) {
      super();
      
    }    

    submitLead(): any {
      this.leadAction.submit().then((response: ng.IHttpPromiseCallbackArg<any>) => {
        this.state.go('landing-thanks');
      });
    }
    
    validateZip(): void {
      this.validateZipAction.submit().then((response) => {
        this.leadAction.field('zip').value = this.validateZipAction.field('zip').value;
        this.state.go('landing-step2', { rep_id: this.params.rep_id });
      });
    }
    
    getSavings(): void {
      
    }
  }

  angular
    .module('powur.landing')
    .controller(LandingController.ControllerId, LandingController);
}
