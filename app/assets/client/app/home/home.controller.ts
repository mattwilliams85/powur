/// <reference path='../_references.ts' />

module powur {
  class HomeController extends AuthController {
    static ControllerId = 'HomeController';
    static $inject = ['$mdSidenav', 'goals', 'requirements'];

    get userData(): any {
      return this.session.properties;
    }
    
    constructor(private $mdSidenav: ng.material.ISidenavService,
                public goals: GoalsModel,
                public requirements: ISirenModel) {
      super();
    }
    
  }
  
  controllerModule.controller(HomeController.ControllerId, HomeController);
}