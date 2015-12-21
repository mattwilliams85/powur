/// <reference path='../../typings/tsd.d.ts' />
/// <reference path='../layout/auth.controller.ts' />

module powur {
  'use strict';

  class NewLeadDialogController {
    static ControllerId = 'NewLeadDialogController';
    static $inject = ['$log', '$mdDialog', 'leads'];

    lead: ISirenModel;
    isEligible: boolean;
    get verifyEligibilityAction(): Action { return this.leads.action('validate_zip') }
    get createAction(): Action { return this.leads.action('create') }
    get updateAction(): Action {
      if (!this.lead) return;
      return this.lead.action('update');
    }
    get submitAction(): Action {
      if (!this.lead) return;
      return this.lead.action('submit');
    }

    get submitting(): boolean {
      return (this.updateAction && this.updateAction.submitting) ||
        (this.submitAction && this.submitAction.submitting);
    }

    constructor(private $log: ng.ILogService,
      public $mdDialog: ng.material.IDialogService,
      public leads: ISirenModel) {

      this.verifyEligibilityAction.clearValues();
      this.createAction.clearValues();
    }

    updateLead(lead) {
      if (this.leads.entities[0].properties.id === lead.properties.id) {
        this.leads.entities[0] = lead;
      }
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

    create() {
      this.createAction.submit().then((response: ng.IHttpPromiseCallbackArg<any>) => {
        this.lead = new SirenModel(response.data);
        this.leads.entities.unshift(this.lead);
      });
    }

    update() {
      this.updateAction.submit().then((response: ng.IHttpPromiseCallbackArg<any>) => {
        this.lead = new SirenModel(response.data);
        this.updateLead(this.lead);
      });
    }

    submitToSC() {
      this.submitAction.submit().then((response: ng.IHttpPromiseCallbackArg<any>) => {
        this.$mdDialog.cancel();
      }, (response: any) => {
        this.updateLead(this.lead);
        if (response.data.error) {
          this.updateAction.field('notes').$error = { message: response.data.error.message };
        }
      });
    }

    cancel() {
      this.$mdDialog.cancel();
    }
  }

  class UpdateLeadDialogController {
    static ControllerId = 'UpdateLeadDialogController';
    static $inject = ['$log', '$mdDialog', 'parentCtrl', 'lead', 'leads'];

    parentCtrl: any;
    lead: any;
    leads: ISirenModel;
    editMode: boolean;

    constructor(private $log: ng.ILogService,
      public $mdDialog: ng.material.IDialogService,
      parentCtrl: ng.IScope,
      lead: any,
      leads: ISirenModel) {

      this.lead = lead;
      this.leads = leads;
      this.parentCtrl = parentCtrl;

      if (this.update) {
        for (var i = 0; i < this.update.fields.length; i++) {
          this.update.fields[i].value = this.lead.properties[this.update.fields[i].name];
        }
      }
    }

    remove() {
      this.delete.submit().then((response: ng.IHttpPromiseCallbackArg<any>) => {
        this.$mdDialog.hide();
        _.remove(this.leads.entities, (i) => {
          return this.lead.properties.id === i.properties.id;
        });
      });
    }

    resendInvite() {
      this.resend.submit().then((response: ng.IHttpPromiseCallbackArg<any>) => {
        this.$mdDialog.hide(response.data);
      });
    }

    updateInvite() {
      this.update.submit().then((response: ng.IHttpPromiseCallbackArg<any>) => {
        this.$mdDialog.hide();
        this.lead.properties = response.data.properties;
      });
    }

    submitToSC() {
      this.submitAction.submit().then((response: ng.IHttpPromiseCallbackArg<any>) => {
        this.$mdDialog.cancel();
      });
    }

    showLink(lead): string {
      return 'https://powur.com/next/join/solar/' + lead.code;
    }

    cancel() {
      this.$mdDialog.cancel();
    }

    get delete(): Action { return this.lead.action('delete') }
    get resend(): Action { return this.lead.action('resend') }
    get update(): Action { return this.lead.action('update') }
    get submitAction(): Action { return this.lead.action('submit') }
    get customer(): any { return this.lead.properties.customer }
  }

  class GridSolarController extends AuthController {
    static ControllerId = 'GridSolarController';
    static $inject = ['leadsSummary', 'leads', '$scope', '$mdDialog', '$timeout'];

    days: number = 0;
    searchQuery: string[];
    showSearch: boolean;
    stage: string[] = ['submit', 'proposal', 'closed won', 'contract', 'install', 'duplicate', 'ineligible', 'closed lost'];
    barLeft: number;
    barRight: number;
    radio: string;
    activeFilters: any = {};
    phaseFilter: string = 'pending';
    summaryFilter: number = 0;

    get insight(): any {
      return this.leadsSummary.properties;
    }

    get filters(): any {
      var keys = _.keys(this.leads.properties.filters);
      return _.filter(keys, function(k) {
        return k !== 'options';
      });
    }

    get dateFilterLabel() {
      return this.summaryFilter == 0 ? 'Lifetime' : 'Last ' + this.summaryFilter + ' days';
    }

    constructor(public leadsSummary: ISirenModel,
      public leads: ISirenModel,
      public $scope: any,
      public $mdDialog: ng.material.IDialogService,
      public $timeout: ng.ITimeoutService) {
      super();

      $timeout(function() {
        angular.element('.test').trigger('click');
      }, 100);
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

        if (data) this.updateEntity(new SirenModel(data));
      });
    }

    leadStatus(lead) {
      if (!lead.properties.invite_status) { return 'incomplete' }
      if (lead.properties.sales_status === 'ineligible') { return 'ineligible' }
      if (lead.properties.data_status === 'ineligible_location') { return 'ineligible' }
      if (lead.properties.sales_status === 'closed_lost' || lead.properties.sales_status === 'duplicate') return;
      return lead.properties.invite_status;
    }

    iconStatus(lead) {
      if (lead.properties.sales_status === 'ineligible' || lead.properties.data_status === 'ineligible_location') return;
      if (lead.properties.sales_status === 'closed_lost' || lead.properties.sales_status === 'duplicate') return 'cancel';
      if (lead.properties.invite_status === 'initiated') return 'drafts';
      return 'mail';
    }

    updateEntity(lead) {
      for (var i = 0; i < this.leads.entities.length; i++) {
        if (this.leads.entities[i].properties.id === lead.properties.id) {
          this.leads.entities[i] = lead;
        }
      }
    }

    showLead(e: MouseEvent, lead) {
      if (lead.properties.submitted_at) {
        this.$mdDialog.show({
          controller: 'UpdateLeadDialogController as dialog',
          templateUrl: 'app/grid/show-lead-popup.solar.html',
          parent: angular.element('body'),
          targetEvent: e,
          clickOutsideToClose: true,
          locals: {
            parentCtrl: this,
            lead: lead,
            leads: this.leads
          }
        });
      } else {
        this.$mdDialog.show({
          controller: 'UpdateLeadDialogController as dialog',
          templateUrl: 'app/grid/show-invite-popup.solar.html',
          parent: angular.element('body'),
          targetEvent: e,
          clickOutsideToClose: true,
          locals: {
            parentCtrl: this,
            lead: lead,
            leads: this.leads
          }
        }).then((data: any) => {
          if (data) this.leads.entities = new SirenModel(data).entities;
        });
      }
    }

    inviteUpdate(e: MouseEvent, lead) {
      this.$mdDialog.show({
        controller: 'UpdateLeadDialogController as dialog',
        templateUrl: 'app/grid/update-invite-popup.solar.html',
        parent: angular.element('body'),
        targetEvent: e,
        clickOutsideToClose: true,
        locals: {
          parentCtrl: this,
          lead: lead
        }
      }).then((data: any) => {
        this.updateEntity(new SirenModel(data));
      });
    }

    get home(): any {
      return this.$scope.home;
    }

    get defaultAvatar(): string {
      return this.home.assets.defaultProfileImg;
    }

    tabBar(e) {
      if (!e) {
        this.barLeft = 0;
        this.barRight = 165;
        return;
      }
      this.barLeft = e.target.offsetLeft;
      this.barRight = e.target.parentElement.offsetWidth - (this.barLeft + e.target.offsetWidth);
    }

    search() {
      var entityType = 'user-team_leads_search';
      this.session.getEntity(SirenModel, entityType,
        { search: this.searchQuery, days: this.days, page: 1 }, true).then((data: ISirenModel) => {
          this.leads = data;
          this.leads.properties.entityType = entityType;
        });
    }

    loadMore() {
      var entityType = 'user-team_leads',
        filterOpts = {},
        page = this.leads.properties.paging.current_page;

      if (this.activeFilters['grid']) entityType = 'user-leads';
      if (this.activeFilters['search']) entityType = entityType + '_search';
      if (Object.keys(this.activeFilters).length) {
        _.forEach(this.activeFilters, (filter: any) => {
          filterOpts[filter.key] = filter.value
        });
      }
      filterOpts['page'] = page;
      this.session.getEntity(SirenModel, entityType, filterOpts, true).then((data: any) => {
        this.leads.properties = data.properties;
        this.leads.properties.entityType = entityType;
        if (!data.entities.length) return;
        this.leads.entities = this.leads.entities.concat(data.entities);
      });
    }

    reloadList() {
      this.searchQuery = null;
      this.leads.properties.paging.current_page = 0;
      this.leads.entities = [];
      this.loadMore();
    }

    removeFilter(filter) {
      if (filter === 'status') {
        this.radio = null;
        this.phaseFilter = 'pending';
        this.tabBar(null);
      }
      if (filter === 'grid') {}
      delete this.activeFilters[filter];
      this.reloadList()
    }

    filter(group: string, key: any, value: any) {
      var label, opt = {};

      if (group === 'status') {
        delete this.activeFilters[group];
      } 
      if (!key) {
        delete this.activeFilters[group];
        this.reloadList()
        return;
      }
      this.activeFilters[group] = {
        group: group,
        key: key,
        value: value
      };
      this.reloadList()
    }

    filterSummary(days){
      var filterOpts = {};
      this.summaryFilter = days;
      if (days) filterOpts = { days: days }
      this.session.getEntity(SirenModel, 'user-leads_summary', filterOpts, true).then((data: any) => {
        this.leadsSummary.properties = data.properties;
      });
    }
  }

  angular
    .module('powur.grid')
    .controller(NewLeadDialogController.ControllerId, NewLeadDialogController)
    .controller(GridSolarController.ControllerId, GridSolarController)
    .controller(UpdateLeadDialogController.ControllerId, UpdateLeadDialogController);
}
