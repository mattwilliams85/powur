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

    get ownedByCurrentUser(): boolean {
      return this.lead.properties.owner.id === this.parentCtrl.session.properties.id;
    }

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

    sendInvite() {
      this.sendInviteAction.submit().then((response: ng.IHttpPromiseCallbackArg<any>) => {
        var newLead = new SirenModel(response.data);
        this.lead.properties = newLead.properties;
        this.lead.actions = newLead.actions;
        this.$mdDialog.hide();
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
        var newLead = new SirenModel(response.data);
        this.lead.properties = newLead.properties;
        this.lead.actions = newLead.actions;
        this.$mdDialog.cancel();
        this.parentCtrl.showLead(null, this.lead);
      });
    }

    showLink(lead): string {
      return this.parentCtrl.session.properties.getsolar_page_url + '/' + lead.code;
    }

    cancel() {
      this.$mdDialog.cancel();
    }

    get delete(): Action { return this.lead.action('delete') }
    get sendInviteAction(): Action { return this.lead.action('invite') }
    get update(): Action { return this.lead.action('update') }
    get submitAction(): Action { return this.lead.action('submit') }
    get customer(): any { return this.lead.properties.customer }
  }

  class GridSolarController extends AuthController {
    static ControllerId = 'GridSolarController';
    static $inject = ['leadsSummary', 'leads', '$scope', '$mdDialog', '$timeout'];

    searchQuery: string[];
    stage: string[] = ['submit', 'proposal', 'closed won', 'contract', 'install', 'duplicate', 'ineligible', 'closed lost'];
    barLeft: number;
    barRight: number;
    radio: string = 'none';
    activeFilters: any = {};
    summaryFilters: any = {};
    phaseFilter: string = 'pending';
    reloading: boolean;

    get insight(): any {
      return this.leadsSummary.properties;
    }

    get getSolarPageLink(): string {
      return this.session.properties.getsolar_page_url;
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
        fullscreen: true,
        clickOutsideToClose: true,
        locals: {
          leads: this.leads,
        }
      }).then((data: any) => {

        if (data) this.updateEntity(new SirenModel(data));
      });
    }

    leadStatus(lead) {
      var item = lead.properties;
      if (!item.invite_status) { return 'incomplete' }
      if (item.sales_status === 'ineligible') { return 'ineligible' }
      if (item.data_status === 'ineligible_location') { return 'ineligible' }
      if (item.sales_status === 'closed_lost' || item.sales_status === 'duplicate') return 'lost';
      return item.invite_status;
    }

    prepareFilterName(name) {
      if (name === 'proposal') return 'qualified';
      return name;
    }

    iconStatus(lead) {
      var item = lead.properties;
      if (item.sales_status === 'ineligible' || item.data_status === 'ineligible_location') return;
      if (item.sales_status === 'closed_lost' || item.sales_status === 'duplicate') return 'cancel';
      if (item.invite_status === 'initiated') return 'drafts';
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
          fullscreen: true,
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
          fullscreen: true,
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
        fullscreen: true,
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

    get currentPage(): any {
      return this.leads.properties.paging.current_page;
    }

    get pageArray(): number[] {
      var array = [];
      var n = 0;
      if (this.currentPage > 5) n = this.currentPage - 5;
      for (var i = n; i < 9 + n; i ++) {
        if (i === this.leads.properties.paging.page_count) break;
        array.push(i)
      }
      return array;
    }

    changePage(i): any {
      this.leads.properties.paging.current_page = i;
      this.loadMore();
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
        this.reloading = false;
        this.leads.properties = data.properties;
        if (!data.entities.length) return;
        this.leads.entities = data.entities;
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
      this.reloading = true;
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

    filterSummary(group: string, key: any, value: any) {
      var filterOpts = {},
          entityType = 'user-leads_summary';
      this.summaryFilters[group] = {
        group: group,
        key: key,
        value: value
      };
      if (Object.keys(this.summaryFilters).length) {
        _.forEach(this.summaryFilters, (filter: any) => {
          if (!filter.value) {
             delete this.summaryFilters[group];
             return;
          };
          filterOpts[filter.key] = filter.value;
        });
      }

      this.session.getEntity(SirenModel, entityType, filterOpts, true).then((data: any) => {
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
