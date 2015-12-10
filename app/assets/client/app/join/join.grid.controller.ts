/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../layout/base.controller.ts' />

module powur {
  'use strict';

  class JoinGridController extends BaseController {
    static ControllerId = 'JoinGridController';
    static $inject = ['$mdDialog', '$stateParams', '$timeout', '$sce', 'invite', 'videoAssets'];

    gridKey: string;
    gridKeyInvalid: boolean;
    gridKeyMissing: boolean;
    leadSubmitAllowed: boolean = false;

    get acceptAction(): Action {
      return this.invite.action('accept_invite');
    }

    get termsPath(): string {
      var terms = this.session.properties.latest_terms || {};
      return terms.document_path;
    }

    constructor(private $mdDialog: ng.material.IDialogService,
                private $stateParams: ng.ui.IStateParamsService,
                private $timeout: ng.ITimeoutService,
                private $sce: ng.ISCEService,
                private invite: ISirenModel,
                private videoAssets: ISirenModel) {
      super();

      if (!_.isEmpty(invite)) {
        this.gridKey = invite.properties.id;
      }

      $timeout(() => {
        this.leadSubmitAllowed = true;
      }, 10000);
    }

    validateGridInviteSubmit(): void {
      this.session.getInvite(this.gridKey).then((response: ng.IHttpPromiseCallbackArg<any>) => {
        this.state.go('join.grid2', { inviteCode: this.gridKey });
      }, () => {
        this.gridKeyInvalid = true;
      });
    }

    acceptSubmit(): void {
      this.acceptAction.submit().then((response: ng.IHttpPromiseCallbackArg<any>) => {
        this.session.refresh().then(() => {
          this.state.go('home.invite.grid');
        });
      });
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

    trustedUrl(path): string {
      return this.$sce.trustAsResourceUrl(path);
    }
  }

  angular
    .module('powur.join')
    .controller(JoinGridController.ControllerId, JoinGridController);
}
