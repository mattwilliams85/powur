/// <reference path='../_references.ts' />

module powur {
  class JoinGridController extends BaseController {
    static ControllerId = 'JoinGridController';
    static $inject = ['$mdDialog', '$stateParams', 'invite'];

    gridInvite: ISirenModel;
    firstName: string;

    constructor(private $mdDialog: ng.material.IDialogService,
                private $stateParams: ng.ui.IStateParamsService,
                private invite: ISirenModel) {
      super();
      this.log.debug(JoinGridController.ControllerId + ':ctor');
      if (this.$stateParams['inviteData']) {
        this.gridInvite = new SirenModel(this.$stateParams['inviteData']);
      }
    }

    get validateGridInvite(): Action {
      return this.session.instance.action('validate_grid_invite');
    }

    get acceptGridInvite(): Action {
      return this.gridInvite.action('accept_invite');
    }

    validateGridInviteSubmit(): void {
      this.validateGridInvite.submit().then((response: ng.IHttpPromiseCallbackArg<any>) => {
        this.gridInvite = new SirenModel(response.data);
        if (this.gridInvite.action('accept_invite')) {
          this.state.go('join.grid2', { inviteData: response.data });
        } else {
          this.state.go('login');
        }
      });
    }

    acceptGridInviteSubmit(): void {
      this.acceptGridInvite.submit().then((response: ng.IHttpPromiseCallbackArg<any>) => {
        this.session.refresh().then(() => {
          this.state.go('home.invite');
        });
      });
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

  controllerModule.controller(JoinGridController.ControllerId, JoinGridController);
}
