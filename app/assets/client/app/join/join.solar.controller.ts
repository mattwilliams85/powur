/// <reference path='../_references.ts' />

//TODO: split solar & grid into seperate controllers
module powur {
  class JoinSolarController extends BaseController {
    static ControllerId = 'JoinSolarController';
    static $inject = ['$mdDialog', '$stateParams', 'customer'];

    get validateZipAction(): Action {
      return this.customer.action('validate_zip');
    }

    get zip(): Field {
      return this.validateZipAction.field('zip');
    }

    constructor(private $mdDialog: ng.material.IDialogService,
                private $stateParams: ng.ui.IStateParamsService,
                private customer: ISirenModel) {
      super();
    }

    validateZip(): void {
        this.validateZipAction.submit().then((response) => {
        var is_valid = response['data']['properties']['is_valid'];

        if (is_valid) {
          this.state.go('join.solar2', { leadData: response.data, inviteCode: this.params.inviteCode });
        } else {
          this.zip.$error = 'Your zipcode is outside the servicable area'
        }
      })
    }

    get solarInvite(): Action {
      return this.session.instance.action('solar_invite');
    }

    // get submitLead(): Action {
    //   return this.solarLead.action('solar_invite');
    // }

    get params(): any {
      return this.$stateParams;
    }

    // createLead(): any {
    //   this.submitLead.submit().then((response: ng.IHttpPromiseCallbackArg<any>) => {
    //       this.state.go('join.solar3');
    //   });
    // }

    enterSolar(): void {
      this.log.debug(JoinSolarController.ControllerId + ':enterGrid');
      this.state.go('join.solar3', {});
    }

    openTerms(ev: ng.IAngularEvent): void {
      this.$mdDialog.show(<any>{
        controller: 'TermsDialogController as terms',
        templateUrl: 'app/join/terms.html',
        parent: angular.element(document.body),
        targetEvent: ev,
        clickOutsideToClose: true
      })
    }
  }

  controllerModule.controller(JoinSolarController.ControllerId, JoinSolarController);
}
