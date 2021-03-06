/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../layout/auth.controller.ts' />

module powur {
  'use strict';

  export class LandingController extends BaseController {
    static ControllerId = 'LandingController';
    static $inject = ['$stateParams', '$scope', 'rep', 'lead', '$anchorScroll'];

    get validateZipAction(): Action {
      return this.rep.action('validate_zip');
    }

    get zip(): Field {
      return this.validateZipAction.field('zip');
    }

    get leadAction(): Action {
      if (this.lead) return this.lead.action('update');
      return this.rep.action('create_lead');
    }

    get params(): any {
      return this.$stateParams;
    }

    get defaultAvatar(): string {
      return this.$scope.root.assets.defaultProfileImg;
    }

    constructor(private $stateParams: ng.ui.IStateParamsService,
                private $scope: any,
                private rep: ISirenModel,
                private lead: ISirenModel,
                private $anchorScroll: any) {
      super();
    }

    submitLead(): any {
      this.leadAction.submit().then((response: ng.IHttpPromiseCallbackArg<any>) => {
        this.state.go('landing-thanks');
        this.$anchorScroll();
      });
    }

    validateZip(): void {
      this.validateZipAction.submit().then((response) => {
        this.leadAction.field('zip').value = this.validateZipAction.field('zip').value;
        if (this.params.inviteCode) {
          this.state.go('landing-invite-step2', {
            repId: this.params.repId,
            inviteCode: this.params.inviteCode });
        } else {
          this.state.go('landing-step2', { repId: this.params.repId });
        }
      });
    }

    processNumberInput(model) {
      model.value = model.value.replace(/[^\d\.]+/, '');
    }
  }

  angular
    .module('powur.landing')
    .controller(LandingController.ControllerId, LandingController);
}
