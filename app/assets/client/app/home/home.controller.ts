/// <reference path='../_references.ts' />

module powur {
  class HomeController extends AuthController {
    static ControllerId = 'HomeController';
    static $inject = ['$mdSidenav', 'goals', 'requirements'];

    get userData(): any {
      return this.session.instance.properties;
    }
    
    constructor(private $mdSidenav: ng.material.ISidenavService,
                public goals: ISirenModel,
                public requirements: ISirenModel) {
      super();

      this.state.transitionTo('home.invite');
    }
    
    openMenu() {
      this.$mdSidenav('left').toggle();
    }
  }
  
  controllerModule.controller(HomeController.ControllerId, HomeController);
}