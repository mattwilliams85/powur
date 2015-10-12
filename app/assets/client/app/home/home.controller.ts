/// <reference path='../_references.ts' />

module powur {
  class HomeController extends AuthController {
    static ControllerId: string = 'HomeController';
    // static $inject = ['$log', '$state', 'SessionService'];

    static $inject = AuthController.$inject.concat('goals');

    get userData(): any {
      return this.$session.instance.properties;
    }
    
    constructor($log: ng.ILogService,
                $state: ng.ui.IStateService,
                $session: ISessionService,
                public goals: ISirenModel) {
      super($log, $state, $session);

      console.log('gogo', goals);

      this.$state.transitionTo('home.invite');
    }
  }
  
  controllerModule.controller(HomeController.ControllerId, HomeController);
}