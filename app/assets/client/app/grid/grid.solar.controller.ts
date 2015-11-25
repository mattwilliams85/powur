/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../layout/auth.controller.ts' />

module powur {
  'use strict';

  class GridSolarController extends AuthController {
    static ControllerId = 'GridSolarController';
    static $inject = ['leadsSummary', 'leads', '$timeout'];

    searchQuery: string;

    get insight(): any {
      return this.leadsSummary.properties;
    }

    constructor(public leadsSummary: ISirenModel,
                public leads: ISirenModel,
                public $timeout: ng.ITimeoutService) {
      super();
    }

    search() {
      this.session.getEntity(SirenModel, 'user-team_leads_search',
        { search: this.searchQuery }, true).then((data: ISirenModel) => {
          this.leads = data;
        });
    }

    showAllLeads() {
      this.session.getEntity(SirenModel, 'user-team_leads',
        { days: 60 }, true).then((data: ISirenModel) => {
          this.leads = data;
        });
    }
  }

  angular
    .module('powur.grid')
    .controller(GridSolarController.ControllerId, GridSolarController);
}
