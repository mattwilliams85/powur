/// <reference path='../../typings/tsd.d.ts' />

module powur {
  class NavController {
    static ControllerId: string = 'NavController';
    static $inject: Array<string> = ['$scope', '$mdSidenav', '$sce'];

    activeMenu: boolean = false;

    get home(): any {
      return this.$scope.home;
    }

    get state(): ng.ui.IStateService {
      return this.home.state;
    }

    constructor(private $scope: any,
                private $mdSidenav: ng.material.ISidenavService,
                private $sce: ng.ISCEService) {
    }

    isCurrent(state: string): boolean {
      return !!this.state.current.name.match(`${state}`);
    }

    isOpen() { return this.$mdSidenav('left').isOpen(); };

    openMenu() {
      this.$mdSidenav('mobile-left').toggle();
    }

    logout() {
      this.home.session.logout();
    }

    get userData(): any {
      return this.home.userData;
    }

    get headshot(): string {
      var avatar = this.userData.avatar;
      var image = avatar ? avatar.large : this.home.assets.defaultProfileImg;
      return `url(${image})`;
    }

    get headshotStyle(): any {
      return { 'background-image': this.headshot };
    }

    get title(): string {
      return this.$sce.trustAsHtml(this.state.params['title']);
    }
  }

  angular
    .module('powur.layout')
    .controller(NavController.ControllerId, NavController);
}
