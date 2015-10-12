/// <reference path='../_references.ts' />

module powur {
  class HomeController extends AuthController {
    static ControllerId = 'HomeController';
    static $inject = ['$state', '$mdSidenav', 'goals'];

    get userData(): any {
      return this.session.instance.properties;
    }
    
    constructor(private $state: ng.ui.IStateService,
                private $mdSidenav: ng.material.ISidenavService,
                public goals: ISirenModel) {
      super();

      this.state.transitionTo('home.invite');
    }
    
    openMenu() {
      this.$mdSidenav('left').toggle();
    }
  }
  
  controllerModule.controller(HomeController.ControllerId, HomeController);
}