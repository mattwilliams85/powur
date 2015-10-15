/// <reference path='../_references.ts' />

module powur {
  interface IHudScope extends ng.IScope {
    home: any;
  }
  
  class HudController {
    static ControllerId = 'HudController';
    static $inject = ['$scope', '$log'];


    get home(): any {
      return this.$scope.home;
    }

    toggleHud(): void{
      if($("md-sidenav").hasClass("collapsed")) {
        $("md-sidenav").removeClass("collapsed");
      }else{
        $("md-sidenav").addClass("collapsed");
      }
    }

    get userData(): any {
      return this.home.userData;
    }

    get rank(): number {
      return this.home.goals.properties.next_rank - 1;
    }

    get rankTotal(): number {
      return this.home.goals.properties.rank_list.length - 1;
    }

    get headshot(): string {
      var avatar = this.userData.avatar;
      var image = avatar ? avatar.large : '/assets/img/default-profile.png';
      return `url(${image})`;
    }

    get headshotStyle(): any {
      return { 'background-image': this.headshot };
    }

    get goalRequirements(): ISirenModel[] {
      return this.home.requirements.entities;
    }
    
    constructor(private $scope: IHudScope,
                private $log: ng.ILogService) {
    }

  }

  controllerModule.controller(HudController.ControllerId, HudController);
}
