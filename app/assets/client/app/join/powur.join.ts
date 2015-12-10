/// <reference path='../../typings/tsd.d.ts' />

module powur {
  'use strict';

  function userVideoAssets(session: ISessionService) {
    return session.getEntity(SirenModel, 'user-video_assets');
  }

  joinConfig.$inject = ['$stateProvider'];

  function joinConfig($stateProvider: ng.ui.IStateProvider) {
    $stateProvider
      .state('join', {
        url: '/join',
        template: '<div ui-view></div>',
        abstract: true
      })
      .state('join.grid', {
        url: '/grid/{inviteCode}',
        templateUrl: 'app/join/join-grid.html',
        controller: 'JoinGridController as join',
        data: {
          logout: true
        },
        resolve: {
          invite: function($stateParams, $q) {
            var root = RootController.get();
            var defer = $q.defer();
            root.$session.getInvite($stateParams.inviteCode).then((response: ng.IHttpPromiseCallbackArg<any>) => {
              defer.resolve(response);
            }, () => {
              defer.resolve({});
            });
            return defer.promise;
          },
          videoAssets: ['SessionService', userVideoAssets]
        }
      })
      .state('join.grid2', {
        url: '/grid/{inviteCode}',
        templateUrl: 'app/join/join-grid2.html',
        controller: 'JoinGridController as join',
        resolve: {
          invite: function($stateParams, $q) {
            var root = RootController.get();
            var fail = function(response) {
              var reason: any = (response.status === 404) ? 'invalid_code' : response;
              return $q.reject(reason);
            }
            return root.$session.getInvite($stateParams.inviteCode).then(null, fail);
          },
          videoAssets: ['SessionService', userVideoAssets]
        }
      })
      .state('join.solar', {
        url: '/solar/{inviteCode}',
        templateUrl: 'app/join/join-solar.html',
        controller: 'JoinSolarController as join',
        data: {
          logout: true
        },
        resolve: {
          customer: function($stateParams, $q) {
            var root = RootController.get();
            var defer = $q.defer();
            root.$session
                .getCustomer($stateParams.inviteCode)
                .then((response: ng.IHttpPromiseCallbackArg<any>) => {
              defer.resolve(response);
            }, () => {
              defer.resolve({});
            });
            return defer.promise;
          }
        }
      })
      .state('join.solar2', {
        url: '/solar/{inviteCode}',
        templateUrl: 'app/join/join-solar2.html',
        controller: 'JoinSolarController as join',
        params: {
          leadData: null
        },
        resolve: {
          customer: function($stateParams, $q) {
            var root = RootController.get();
            var fail = function(response) {
              var reason: any = (response.status === 404) ? 'invalid_code' : response;
              return $q.reject(reason);
            }
            return root.$session.getCustomer($stateParams.inviteCode).then(null, fail);
          }
        }
      })
      .state('join.solar3', {
        url: '/solar',
        templateUrl: 'app/join/join-solar3.html'
      });
  }

  angular
    .module('powur.join', ['powur.core'])
    .config(joinConfig);
}
