/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../services/session.service.ts' />

module powur {
  'use strict';

  function userLeadsMarketing(session: ISessionService) {
    return session.getEntity(SirenModel, 'user-leads_marketing', {}, true);
  }

  function userLeadsSummary(session: ISessionService) {
    return session.getEntity(SirenModel, 'user-leads_summary', {}, true);
  }

  function userTeamLeads(session: ISessionService) {
    return session.getEntity(SirenModel, 'user-team_leads', { page: 1 });
  }

  function userTeamSummary(session: ISessionService) {
      return session.getEntity(SirenModel, 'user-grid_summary', {}, true);
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
        params: { title: 'solar <b>grid</b>' },
        resolve: {
          leadsMarketing: ['SessionService', userLeadsMarketing],
          leadsSummary: ['SessionService', userLeadsSummary],
          leads: ['SessionService', userTeamLeads]
        }
      })
      .state('home.grid.powur', {
        url: '/powur',
        templateUrl: 'app/grid/grid.powur.html',
        controller: 'GridPowurController as grid',
        params: { title: 'powur <b>grid</b>' },
        resolve: {
          teamSummary: ['SessionService', userTeamSummary]
        }
      });
  }

  angular
    .module('powur.grid', ['powur.core'])
    .config(inviteConfig);
}
