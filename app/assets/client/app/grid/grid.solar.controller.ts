/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../layout/auth.controller.ts' />

module powur {
  'use strict';

  class NewLeadDialogController {
    static ControllerId = 'NewLeadDialogController';
    static $inject = ['$log', '$mdDialog', 'leads'];

    isEligible: boolean;
    get verifyEligibilityAction(): Action { return this.leads.action('validate_zip') }

    constructor(private $log: ng.ILogService,
                public $mdDialog: ng.material.IDialogService,
                public leads: ISirenModel) {

      this.isEligible = false;
      this.verifyEligibilityAction.field('zip').$error = {};
      this.verifyEligibilityAction.field('zip').value = '';
    }

    verifyEligibility() {
      this.verifyEligibilityAction.submit().then((response: ng.IHttpPromiseCallbackArg<any>) => {
        if (response.data.properties.is_valid) {
          this.isEligible = true;
        } else {
          this.verifyEligibilityAction.field('zip').$error = { message: 'ineligible zip code' };
        }
      });
    }

    cancel() {
      this.$mdDialog.cancel();
    }
  }

  class GridSolarController extends AuthController {
    static ControllerId = 'GridSolarController';
    static $inject = ['leadsSummary', 'leads', '$mdDialog', '$timeout'];

    days: number = 60;
    searchQuery: string;
    showSearch: boolean;

    get insight(): any {
      return this.leadsSummary.properties;
    }

    constructor(public leadsSummary: ISirenModel,
                public leads: ISirenModel,
                public $mdDialog: ng.material.IDialogService,
                public $timeout: ng.ITimeoutService) {
      super();
    }

    addLead(e: MouseEvent) {
      this.$mdDialog.show({
        controller: 'NewLeadDialogController as dialog',
        templateUrl: 'app/grid/new-lead-popup.html',
        parent: angular.element('body'),
        targetEvent: e,
        clickOutsideToClose: true,
        locals: {
          leads: this.leads,
        }
      }).then((data: any) => {
        //
      });
    }

    search() {
      var entityType = 'user-team_leads_search';
      this.session.getEntity(SirenModel, entityType,
        { search: this.searchQuery, days: this.days, page: 1 }, true).then((data: ISirenModel) => {
          this.leads = data;
          this.leads.properties.entityType = entityType;
        });
    }

    showLeads(entityType: string) {
      this.showSearch = false;
      this.session.getEntity(SirenModel, entityType,
        { days: this.days, page: 1 }, true).then((data: ISirenModel) => {
          this.leads = data;
          this.leads.properties.entityType = entityType;
        });
    }

    loadMore() {
      var page = this.leads.properties.paging.current_page,
          opts = {
            days: this.days,
            page: page + 1,
            search: this.searchQuery
          },
          entityType = this.leads.properties.entityType || 'user-team_leads';

      if (this.leads.properties.filters) {
        for (var key in this.leads.properties.filters) {
          opts[key] = this.leads.properties.filters[key];
        }
      }

      this.session.getEntity(SirenModel, entityType, opts, true).then((data: any) => {
        if (!data.entities.length) return;
        this.leads.entities = this.leads.entities.concat(data.entities);
        this.leads.properties = data.properties;
        this.leads.properties.entityType = entityType;
      });
    }
  }

  angular
    .module('powur.grid')
    .controller(NewLeadDialogController.ControllerId, NewLeadDialogController)
    .controller(GridSolarController.ControllerId, GridSolarController);
}
