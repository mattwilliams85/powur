/// <reference path='../typings/tsd.d.ts' />
/// <reference path='../typings/references.d.ts' />

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
            .state('home', {
                templateUrl: 'app/home/home.html',
                controller: 'HomeController as home',
            })
            .state('login', {
                templateUrl: 'app/login/login.html',
                controller: 'LoginController as login',
            })
            .state('marketing', {
                templateUrl: 'app/marketing/marketing.html',
                controller: 'MarketingController as marketing',
            })
            .state('home.invite', {
                url: '/invite',
                views: {
                    'nav': {
                        templateUrl: 'app/layout/nav.html',
                        controller: 'NavController as nav',
                    },
                    'profile': {
                        templateUrl: 'app/profile/profile.html',
                        controller: 'ProfileController as profile',
                    },
                    'main': {
                        templateUrl: 'app/invite/invite.html',
                        controller: 'InviteController as invite',
                    },
                    'activity': {
                        templateUrl: 'app/layout/activity.html',
                        controller: 'ActivityController as activity',
                    },
                },
            })
            .state('home.events', {
                url: '/events',
                views: {
                    'nav': {
                        templateUrl: 'app/layout/nav.html',
                        controller: 'NavController as nav',
                    },
                    'profile': {
                        templateUrl: 'app/profile/profile.html',
                        controller: 'ProfileController as profile',
                    },
                    'main': {
                        templateUrl: 'app/events/events.html',
                        controller: 'EventsController as events',
                    },
                    'activity': {
                        templateUrl: 'app/layout/activity.html',
                        controller: 'ActivityController as activity',
                    },
                },
            })
            .state('home.grid', {
                url: '/grid',
                views: {
                    'nav': {
                        templateUrl: 'app/layout/nav.html',
                        controller: 'NavController as nav',
                    },
                    'profile': {
                        templateUrl: 'app/profile/profile.html',
                        controller: 'ProfileController as profile',
                    },
                    'main': {},
                    'activity': {
                        templateUrl: 'app/layout/activity.html',
                        controller: 'ActivityController as activity',
                    },
                },
            })
            .state('home.goal', {
                url: '/goal',
                views: {
                    'nav': {
                        templateUrl: 'app/layout/nav.html',
                        controller: 'NavController as nav',
                    },
                    'profile': {
                        templateUrl: 'app/profile/profile.html',
                        controller: 'ProfileController as profile',
                    },
                    'main': {},
                    'activity': {
                        templateUrl: 'app/layout/activity.html',
                        controller: 'ActivityController as activity',
                    },
                },
            })
            .state('home.earnings', {
                url: '/earnings',
                views: {
                    'nav': {
                        templateUrl: 'app/layout/nav.html',
                        controller: 'NavController as nav',
                    },
                    'profile': {
                        templateUrl: 'app/profile/profile.html',
                        controller: 'ProfileController as profile',
                    },
                    'main': {},
                    'activity': {
                        templateUrl: 'app/layout/activity.html',
                        controller: 'ActivityController as activity',
                    },
                },
            })
            .state('home.certs', {
                url: '/certs',
                views: {
                    'nav': {
                        templateUrl: 'app/layout/nav.html',
                        controller: 'NavController as nav',
                    },
                    'profile': {
                        templateUrl: 'app/profile/profile.html',
                        controller: 'ProfileController as profile',
                    },
                    'main': {},
                    'activity': {
                        templateUrl: 'app/layout/activity.html',
                        controller: 'ActivityController as activity',
                    },
                },
            })
            .state('home.stats', {
                url: '/stats',
                views: {
                    'nav': {
                        templateUrl: 'app/layout/nav.html',
                        controller: 'NavController as nav',
                    },
                    'profile': {
                        templateUrl: 'app/profile/profile.html',
                        controller: 'ProfileController as profile',
                    },
                    'main': {},
                    'activity': {
                        templateUrl: 'app/layout/activity.html',
                        controller: 'ActivityController as activity',
                    },
                },
            });
    
        }
    }

    appModule.config(RouteConfigs);
}
