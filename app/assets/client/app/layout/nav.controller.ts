/// <reference path='../../typings/tsd.d.ts' />

module powur {
  class NavController {
    static ControllerId: string = 'NavController';
    static $inject: Array<string> = ['$scope', '$mdSidenav'];

    activeMenu: boolean = false;

    get home(): any {
      return this.$scope.home;
    }

    get state(): ng.ui.IStateService {
      return this.home.state;
    }
    
    constructor(private $scope: any, private $mdSidenav: ng.material.ISidenavService) {
    }
    
    isCurrent(state: string): boolean {
      return !!this.state.current.name.match(`${state}`);
    }

    // TODO: Add animation to side, prevent mobile toggle and desktop toggle combo
    isOpen() { return this.$mdSidenav('left').isOpen(); };

    openMenu() {
      this.$mdSidenav('mobile-left').toggle();
    }

    logout() {
      this.home.session.logout();
    }
  }
  
  angular
    .module('powur.layout')
    .controller(NavController.ControllerId, NavController);
}