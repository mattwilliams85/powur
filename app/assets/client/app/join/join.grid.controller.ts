/// <reference path='../_references.ts' />

module powur {
  class JoinGridController extends BaseController {
    static ControllerId = 'JoinGridController';
    static $inject = ['$mdDialog', '$stateParams', 'invite'];

    gridKey: string;
    gridKeyInvalid: boolean;
    gridKeyMissing: boolean;

    get acceptAction(): Action {
      return this.invite.action('accept_invite');
    }

    constructor(private $mdDialog: ng.material.IDialogService,
                private $stateParams: ng.ui.IStateParamsService,
                private invite: ISirenModel) {
      super();

      this.gridKey = invite.properties.id;
    }

    validateGridInviteSubmit(): void {
      if (this.gridKey === this.invite.properties.id) {
        this.state.go('join.grid2', {});
      } else {
        console.log('key', this.gridKey);
        if (this.gridKey) {
          this.gridKeyMissing = false;
          this.gridKeyInvalid = true;
        } else {
          this.gridKeyMissing = true;
        }
      }
    }

    acceptSubmit(): void {
      this.acceptAction.submit().then((response: ng.IHttpPromiseCallbackArg<any>) => {
        this.session.refresh().then(() => {
          this.state.go('home.invite');
        });
      });
    }

    openTerms(ev: ng.IAngularEvent): void {
      this.$mdDialog.show(<any>{
        controller: 'TermsDialogController as terms',
        templateUrl: 'app/join/trailer.html',
        parent: angular.element(document.body),
        targetEvent: ev,
        clickOutsideToClose: true
      })
    }
  }

  controllerModule.controller(JoinGridController.ControllerId, JoinGridController);
}
