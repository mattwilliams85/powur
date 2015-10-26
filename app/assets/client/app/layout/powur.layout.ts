/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../services/session.service.ts' />
/// <reference path='../models/goals.model.ts' />

module powur {
  'use strict';

  function goals(session: ISessionService) {
    return session.getEntity(GoalsModel, 'user-goals');
  }

  function requirements(goals: GoalsModel) {
    return goals ? goals.getRequirements() : [];
  }

  homeConfig.$inject = ['$stateProvider'];

  function homeConfig($stateProvider: ng.ui.IStateProvider) {
    $stateProvider
      .state('home', {
        abstract: true,
        templateUrl: 'app/layout/home.html',
        controller: 'HomeController as home',
        resolve: {
          goals: ['SessionService', goals],
          requirements: requirements
        }
      });
  }

  angular
    .module('powur.layout', ['powur.core'])
    .config(homeConfig);
}
