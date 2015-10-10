/// <reference path='../_references.ts' />

module powur {
    class RootController {
        private session: ISessionModel;
        static ControllerId = 'RootController';
        static $inject = ['$log', '$mdSidenav', '$state', '$location', 'CacheService', 'SessionService'];
        
        constructor(private $log: ng.ILogService,
                    private $mdSidenav: any,
                    private $state: ng.ui.IStateService,
                    private $location: ng.ILocationService,
                    private cache: ICacheService,
                    private sessionService: ISessionService) {
            this.$log.debug(RootController.ControllerId + ':ctor');
            
            this.session = sessionService.session;

            // TODO: write login check
            var isLogin = this.cache.user != null;
            var path = this.$location.path();
            var pages = ['/marketing']; // '/marketing/step2' , '/terms'
            
            if (pages.indexOf(path) !== -1) {
                //pages available for login and not
            } else { 
                // if (isLogin) {
                //     self.$state.transitionTo('home');
                // } else {
                //     self.$state.transitionTo('login');
                // }
            }
        }
        
        openMenu() {
            this.$mdSidenav('left').toggle();
        }
      
    }
    
    controllerModule.controller(RootController.ControllerId, RootController);
}
