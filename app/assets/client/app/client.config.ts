/// <reference path='../typings/tsd.d.ts' />
declare var appModule: ng.IModule;
    
module powur {
    class RouteConfigs {
        public static $inject: Array<string> = ['$locationProvider', '$stateProvider', '$urlRouterProvider', '$httpProvider'];
        
        constructor($locationProvider: ng.ILocationProvider, $stateProvider: ng.ui.IStateProvider, $urlRouterProvider: ng.ui.IUrlRouterProvider, $httpProvider: ng.IHttpProvider) {
            // check auth on api calls
            $httpProvider.interceptors.push('AuthInterceptor');
        
            // default for unknown
            $urlRouterProvider.otherwise('/');

            // use the HTML5 History API
            $locationProvider.html5Mode(true);
            
            // routes
            $stateProvider
            .state('login', {
                url: '/',
                templateUrl: 'app/login/login.html',
                controller: 'LoginController as login',
            })
            
            .state('join', {
                url: '/join',
                templateUrl: 'app/join/join.html',
                controller: 'JoinController as join',
            })
            .state('join2', {
                url: '/join',
                templateUrl: 'app/join/join-step2.html',
                controller: 'JoinController as join',
            })
                        
            .state('home', {
                templateUrl: 'app/home/home.html',
                controller: 'HomeController as home',
            })
            .state('home.invite', {
                url: '/invite',
                views: {
                    'main': {
                        templateUrl: 'app/invite/invite.html',
                        controller: 'InviteController as invite',
                    }
                },
            })
            .state('home.events', {
                url: '/events',
                views: {
                    'main': {
                        templateUrl: 'app/events/events.html',
                        controller: 'EventsController as events',
                    }
                },
            });
    
        }
    }

    appModule.config(RouteConfigs);
}
