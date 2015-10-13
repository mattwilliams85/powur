/// <reference path='../_references.ts' />

module powur {
  class JoinController extends BaseController {
    static ControllerId: string = 'JoinController';
    static $inject: Array<string> = ['$mdDialog', 'CacheService', '$stateParams'];

    firstName: string;
    lastName: string;
    address: string;
    city: string;
    stateStr: string;
    zip: string;
    inviteCode: string;
    gridInvite: SirenModel;

    password: string;

    constructor(private $mdDialog: ng.material.IDialogService,
                private cache: ICacheService,
                private $stateParams: ng.ui.IStateParamsService) {
      super();
      this.log.debug(JoinController.ControllerId + ':ctor');
      this.validate.field('code').value = this.params.inviteCode;
      if (this.state.current.name === 'join.solar') this.setParams();
      if (this.$stateParams['inviteData']) {
        this.gridInvite = new SirenModel(this.$stateParams['inviteData']);
      }
    }

    validateZip(): void {
      var self = this;
      this.validate.submit().then(function(data){
        var is_valid = data['data']['properties']['is_valid'];
        if (is_valid) {
          self.state.go('join.solar2', {});
        } else {
          self.validate.field('zip').$error = 'Your zipcode is outside the servicable area'
        }
      })
    }

    get validate(): Action {
      return this.session.instance.action('validate_zip');
    }

    get solarInvite(): Action {
      return this.session.instance.action('solar_invite');
    }

    get validateGridInvite(): Action {
      return this.session.instance.action('validate_grid_invite');
    }

    get acceptInvite(): Action {
      return this.gridInvite.action('accept_invite');
    }

    get params(): any {
      return this.$stateParams;
    }

    setParams(): void {
      var self = this;
      this.validate.field('code').value = this.params.inviteCode;
      this.solarInvite.href += this.params.inviteCode;
      this.solarInvite.submit().then(function(data){
        self.firstName = data['data']['properties']['first_name'] || "Anonymous";
      });
    }

    validateGridInviteSubmit(): void {
      var self = this;
      this.validateGridInvite.submit().then((response: ng.IHttpPromiseCallbackArg<any>) => {
        self.state.go('join.grid2', { inviteData: response.data });
      });
    }

    acceptInviteSubmit(): void {
      var self = this;
      this.acceptInvite.submit().then((response: ng.IHttpPromiseCallbackArg<any>) => {
alert('not implemented yet');
      });
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
