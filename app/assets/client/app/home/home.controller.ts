/// <reference path='../_references.ts' />

module powur {
  class HomeController extends AuthController {
    static ControllerId: string = 'HomeController';
    static $inject = ['$state', '$mdSidenav', 'goals'];

    get userData(): any {
      return this.root.$session.instance.properties;
    }
    
    constructor(private $state: ng.ui.IStateService, private $mdSidenav: ng.material.ISidenavService, public goals: ISirenModel) {
      super();
      this.root.$log.debug('gogo', goals);

      this.$state.transitionTo('home.invite');
    }
    
    openMenu() {
      this.$mdSidenav('left').toggle();
    }

  }
  
  controllerModule.controller(HomeController.ControllerId, HomeController);
}