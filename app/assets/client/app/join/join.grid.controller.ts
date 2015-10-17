/// <reference path='../_references.ts' />

module powur {
  class JoinGridController extends BaseController {
    static ControllerId = 'JoinGridController';
    static $inject = ['$mdDialog', '$stateParams', '$timeout', 'invite'];

    gridKey: string;
    gridKeyInvalid: boolean;
    gridKeyMissing: boolean;
    leadSubmitAllowed: boolean = false;

    get acceptAction(): Action {
      return this.invite.action('accept_invite');
    }

    constructor(private $mdDialog: ng.material.IDialogService,
                private $stateParams: ng.ui.IStateParamsService,
                private $timeout: ng.ITimeoutService,
                private invite: ISirenModel) {
      super();

      this.gridKey = invite.properties.id;

      $timeout(() => {
        this.leadSubmitAllowed = true;
      }, 30000);
    }

    validateGridInviteSubmit(): void {
      if (this.gridKey === this.invite.properties.id) {
        this.state.go('join.grid2', { inviteCode: this.gridKey });
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

    openTrailer(ev: ng.IAngularEvent, id: string): void {
      this.$mdDialog.show(<any>{
        templateUrl: 'app/join/trailer2.html',
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

  controllerModule.controller(JoinGridController.ControllerId, JoinGridController);
}
