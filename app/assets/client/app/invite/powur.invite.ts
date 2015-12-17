/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../services/session.service.ts' />

module powur {
  'use strict';

  function userInvites(session: ISessionService) {
    return session.getEntity(SirenModel, 'user-invites', { page: 1 });
  }

  inviteConfig.$inject = ['$stateProvider'];

  function inviteConfig($stateProvider: ng.ui.IStateProvider) {
    $stateProvider
      .state('home.invite', {
        url: '/invite',
        templateUrl: 'app/invite/layout.html',
        controller: 'InviteController as invite',

      })
      .state('home.invite.grid', {
        url: '/grid',
        templateUrl: 'app/invite/invite.grid.html',
        controller: 'InviteGridController as invite',
        params: { title: 'powur <b>invite</b>' },
        resolve: {
          invites: ['SessionService', userInvites]
        }
      });
  }

  angular
    .module('powur.invite', ['powur.core'])
    .config(inviteConfig);
}
