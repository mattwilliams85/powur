/// <reference path='../../typings/tsd.d.ts' />

module powur {
  class NavController {
    static ControllerId: string = 'NavController';
    static $inject: Array<string> = ['$scope', '$mdSidenav', '$sce'];

    activeMenu: boolean = false;
    menu: any = {};

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

    menuPosition(e, active) {
      this.menu.active = active;
      if (!$(e.target).hasClass('menu-item')) return;
      var offset = e.target.offsetTop;
      var linkHeight = $(e.target).find('.link-item').height();
      var height = ($(e.target).find('.sub-menu').children().length * linkHeight);

      if (height + offset < window.innerHeight) {
        this.menu.position = 'top';
      } else {
        this.menu.position = 'bottom';
      }
    };

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
