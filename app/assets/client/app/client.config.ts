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
            
            .state('marketing', {
                url: '/marketing',
                templateUrl: 'app/marketing/marketing.html',
                controller: 'MarketingController as marketing',
            })
            .state('marketing2', {
                url: '/marketing/step2',
                templateUrl: 'app/marketing/marketing-step2.html',
                controller: 'MarketingController as marketing',
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
