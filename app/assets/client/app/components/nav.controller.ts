/// <reference path='../_references.ts' />

module powur {
  class NavController {
    static ControllerId: string = 'NavController';
    static $inject: Array<string> = ['$scope', '$mdSidenav'];

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
    openMenu() {
      console.log('fuck')
      this.$mdSidenav('left').toggle();
    }

    logout() {
      this.home.session.logout().then((r: ng.IHttpPromiseCallbackArg<any>) => {
        this.state.go('login.public');
      })
    }
  }
  
  controllerModule.controller(NavController.ControllerId, NavController);
}