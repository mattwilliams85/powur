/// <reference path='../typings/tsd.d.ts' />
/// <reference path='../typings/references.d.ts' />

module powur {
    class RouteConfigs {
        public static $inject: Array<string> = ['$stateProvider', '$urlRouterProvider', '$httpProvider'];
        
        constructor($stateProvider: ng.ui.IStateProvider, $urlRouterProvider: ng.ui.IUrlRouterProvider, $httpProvider: ng.IHttpProvider) {
            // check auth on api calls
            $httpProvider.interceptors.push('AuthInterceptor');
        
            // default for unknown
            $urlRouterProvider.otherwise('/');
            
            // routes
            $stateProvider
            .state('home', {
                url: '/',
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
                        templateUrl: 'app/home/home.html',
                        controller: 'HomeController as home',
                    },
                    'activity': {
                        templateUrl: 'app/layout/activity.html',
                        controller: 'ActivityController as activity',
                    },
                },
            })
            .state('login', {
                url: '/login',
                views: {
                    'nav': {},
                    'profile': {},
                    'main': {
                        templateUrl: 'app/login/login.html',
                        controller: 'LoginController as login',
                    },
                    'activity': {},
                },
            })
            .state('invite', {
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
            .state('events', {
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
            .state('grid', {
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
            .state('goal', {
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
            .state('earnings', {
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
            .state('certs', {
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
            .state('stats', {
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
