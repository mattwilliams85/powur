/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../services/session.service.ts' />

module powur {
  'use strict';

  function productInvites(session: ISessionService) {
    return session.getEntity(SirenModel, 'user-product_invites', { page: 1 });
  }

  function userInvites(session: ISessionService) {
      return session.getEntity(SirenModel, 'user-invites');
  }

  inviteConfig.$inject = ['$stateProvider'];

  function inviteConfig($stateProvider: ng.ui.IStateProvider) {
      $stateProvider
        .state('home.invite', {
            url: '/invite',
            templateUrl: 'app/invite/layout.html',
            controller: 'InviteController as invite',
        })
        .state('home.invite.product', {
            url: '/solar',
            templateUrl: 'app/invite/invite.product.html',
            controller: 'InviteProductController as invite',
            resolve: {
              invites: ['SessionService', productInvites]
            }
        })
        .state('home.invite.grid', {
            url: '/grid',
            templateUrl: 'app/invite/invite.grid.html',
            controller: 'InviteGridController as invite',
            resolve: {
              invites: ['SessionService', userInvites]
            }
        });

  }

  angular
    .module('powur.invite', ['powur.core'])
    .config(inviteConfig);
}
