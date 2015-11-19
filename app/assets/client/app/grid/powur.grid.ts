/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../services/session.service.ts' />

module powur {
  'use strict';

  function userLeadsSummary(session: ISessionService) {
    return session.getEntity(SirenModel, 'user-leads_summary', { days: 30 });
  }

  inviteConfig.$inject = ['$stateProvider'];

  function inviteConfig($stateProvider: ng.ui.IStateProvider) {
    $stateProvider
      .state('home.grid', {
        url: '/grid',
        template: '<div ui-view></div>',
        abstract: true
      })
      .state('home.grid.solar', {
        url: '/solar',
        templateUrl: 'app/grid/grid.solar.html',
        controller: 'GridSolarController as grid',
        resolve: {
          leadsSummary: ['SessionService', userLeadsSummary]
        }
      })
      .state('home.grid.powur', {
        url: '/powur',
        templateUrl: 'app/grid/grid.powur.html',
        controller: 'GridPowurController as grid'
      });
  }

  angular
    .module('powur.grid', ['powur.core'])
    .config(inviteConfig);
}
