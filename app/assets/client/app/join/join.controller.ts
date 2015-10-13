/// <reference path='../_references.ts' />

//TODO: split solar & grid into seperate controllers
module powur {
  class JoinController extends BaseController {
    static ControllerId: string = 'JoinController';
    static $inject: Array<string> = ['$mdDialog', 'CacheService', '$stateParams'];

    gridInvite: SirenModel;
    solarLead: SirenModel;
    firstName: string;

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
      if (this.$stateParams['leadData']) {
        this.solarLead = new SirenModel(this.$stateParams['leadData']);
      }
    }

    validateZip(): void {
      var self = this;
      this.validate.submit().then(function(response){
        var is_valid = response['data']['properties']['is_valid'];
        if (is_valid) {
          self.state.go('join.solar2', { leadData: response.data });
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

    get submitLead(): Action {
      return this.solarLead.action('solar_invite');
    }

    get validateGridInvite(): Action {
      return this.session.instance.action('validate_grid_invite');
    }

    get acceptGridInvite(): Action {
      return this.gridInvite.action('accept_invite');
    }

    get params(): any {
      return this.$stateParams;
    }

    createLead(): any {
      var self = this;
      this.submitLead.submit().then(function(data) {
        self.state.go('join.solar3');
      });
    }

    setParams(): void {
      var self = this;
      this.validate.field('code').value = this.params.inviteCode;
      this.solarInvite.href += this.params.inviteCode;
      this.solarInvite.submit().then(function(data){
        self.firstName = data['data']['properties']['first_name'] || "Anonymous";
      }, function(){
        self.firstName = "Anonymous";
      });
    }

    validateGridInviteSubmit(): void {
      var self = this;
      this.validateGridInvite.submit().then((response: ng.IHttpPromiseCallbackArg<any>) => {
        self.gridInvite = new SirenModel(response.data);
        if (self.gridInvite.action('accept_invite')) {
          self.state.go('join.grid2', { inviteData: response.data });
        } else {
          self.state.go('login');
        }
      });
    }

    acceptGridInviteSubmit(): void {
      var self = this;
      this.acceptGridInvite.submit().then((response: ng.IHttpPromiseCallbackArg<any>) => {
        self.session.refresh().then(() => {
          self.state.go('home.invite');
        });
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
