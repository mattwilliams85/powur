/// <reference path='../_references.ts' />

module powur {
  class JoinController extends BaseController {
    static ControllerId: string = 'JoinController';
    static $inject: Array<string> = ['$mdDialog', 'CacheService','$stateParams'];

    //step 1
    gridKey: string;
    zipKey: string;

    // step 2
    firstName: string;
    lastName: string;
    address: string;
    city: string;
    stateStr: string;
    zip: string;
    inviteCode: string;

    password: string;

    constructor(private $mdDialog: ng.material.IDialogService,
                private cache: ICacheService,
                private $stateParams: ng.ui.IStateParamsService) {
      super();
      this.log.debug(JoinController.ControllerId + ':ctor');
      // this.fetchName();
    }

    continue(state: string): void {
      // debugger
      // this.log.debug(JoinController.ControllerId + ':continue');
      // this.log.debug(this.gridKey);
      // this.state.go(state, {});
    }

    get validate(): Action {
      return this.session.instance.action('validate_zipcode');
    }

    get solarInvite(): Action {
      return this.session.instance.action('solar_invite');
    }

    get validateGridInvite(): Action {
      return this.session.instance.action('validate_grid_invite');
    }

    get params(): any {
      return this.$stateParams;
    }

    fetchName(): void {
      var self = this;
      this.solarInvite.href += this.params.inviteCode;
      this.solarInvite.submit().then(function(data){
        self.firstName = data['data']['properties']['first_name'] || "Anonymous";
      });
    }

    validateGridInviteSubmit(): void {
      var self = this;
      this.validateGridInvite.submit().then(() => {
        self.state.go('join.grid2', {});
      });
    }

    enterGrid(): void {
      this.log.debug(JoinController.ControllerId + ':enterGrid');
      this.state.go('home', {});
    }

    enterSolar(): void {
      this.log.debug(JoinController.ControllerId + ':enterGrid');
      this.state.go('join.solar3', {});
    }

    openTerms(ev: ng.IAngularEvent): void {
      this.$mdDialog.show(<any>{
        controller: 'TermsDialogController as terms',
        templateUrl: 'app/join/terms.html',
        parent: angular.element(document.body),
        targetEvent: ev,
        clickOutsideToClose:true
      })
    }
  }

  controllerModule.controller(JoinController.ControllerId, JoinController);
}
