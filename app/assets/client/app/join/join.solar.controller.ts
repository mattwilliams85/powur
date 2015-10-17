/// <reference path='../_references.ts' />

module powur {
  class JoinSolarController extends BaseController {
    static ControllerId = 'JoinSolarController';
    static $inject = ['$mdDialog', '$stateParams', 'customer'];

    videoId: string;

    get params(): any {
      return this.$stateParams;
    }

    get validateZipAction(): Action {
      return this.customer.action('validate_zip');
    }

    get zip(): Field {
      return this.validateZipAction.field('zip');
    }

    get leadAction(): Action {
      return this.customer.action('submit_lead');
    }

    constructor(private $mdDialog: ng.material.IDialogService,
                private $stateParams: ng.ui.IStateParamsService,
                private customer: ISirenModel) {
      super();
    }

    validateZip(): void {
      this.validateZipAction.submit().then((response) => {
        this.state.go('join.solar2', { inviteCode: this.params.inviteCode });
      });
    }

    get solarInvite(): Action {
      return this.session.instance.action('solar_invite');
    }

    submitLead(): any {
      this.leadAction.submit().then((response: ng.IHttpPromiseCallbackArg<any>) => {
        this.state.go('join.solar3');
      });
    }

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

    openTrailer(ev: ng.IAngularEvent, id: string): void {
      this.$mdDialog.show(<any>{
        templateUrl: 'app/join/trailer.html',
        controller: 'JoinSolarController as join',
        parent: $('.join'),
        targetEvent: ev,
        clickOutsideToClose: true,
        locals: {
          customer: {}
        }
      })
    }
  }

  controllerModule.controller(JoinSolarController.ControllerId, JoinSolarController);
}
