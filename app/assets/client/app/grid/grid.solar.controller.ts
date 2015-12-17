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
      });
    }

    update() {
      this.updateAction.submit().then((response: ng.IHttpPromiseCallbackArg<any>) => {
        this.lead = new SirenModel(response.data);
      });
    }

    submitToSC() {
      this.submitAction.submit().then((response: ng.IHttpPromiseCallbackArg<any>) => {
        this.$mdDialog.cancel();
      }, (response: any) => {
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
      static $inject = ['$log', '$mdDialog', 'parentCtrl', 'lead'];

      parentCtrl: any;
      lead: any;
      editMode: boolean;

      constructor(private $log: ng.ILogService,
                  public $mdDialog: ng.material.IDialogService,
                  parentCtrl: ng.IScope,
                  lead: any) {

        this.lead = lead
        this.parentCtrl = parentCtrl;

        if (this.update) {
          for (var i = 0; i < this.update.fields.length; i++) {
            this.update.fields[i].value = this.lead.properties[ this.update.fields[i].name ];
          }
        }
      }

      remove() {
        this.delete.submit().then((response: ng.IHttpPromiseCallbackArg<any>) => {
          this.$mdDialog.hide(response.data);
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
      get customer(): any  { return this.lead.properties.customer }
  }

  class GridSolarController extends AuthController {
    static ControllerId = 'GridSolarController';
    static $inject = ['leadsSummary', 'leads', '$scope', '$mdDialog', '$timeout'];

    mainFilter: string;
    days: number = 60;
    searchQuery: string;
    showSearch: boolean;
    stage: string[] = ['submit', 'qualify', 'closed won', 'contract', 'install', 'duplicate', 'ineligible', 'closed lost'];
    barLeft: number;
    barRight: number;
    activeFilter: string;

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
      return 'Last ' + this.days + ' days';
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
        if (data) this.leads = new SirenModel(data);
      });
    }

    leadStatus(lead) {
      if (!lead.properties.invite_status) { return 'incomplete' }
      if (lead.properties.sales_status === 'ineligible') { return 'ineligible' }
      return lead.properties.invite_status;
    }

    iconStatus(lead) {
      if (lead.properties.sales_status === 'ineligible') return;
      if (lead.properties.sales_status === 'closed_lost') return 'cancel';
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
            lead: lead
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
            lead: lead
          }
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

    tabBar(e){
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
      var page = this.leads.properties.paging.current_page,
          opts = { days: this.days, page: page + 1, search: this.searchQuery },
          entityType = this.leads.properties.entityType || 'user-team_leads';

      if (this.leads.properties.filters) {
        var filterValue;
        _.forEach(this.filters, (key: string) => {
          filterValue = this.leads.properties.filters[key];
          if (filterValue) opts[key] = filterValue;
        });
      }

      this.session.getEntity(SirenModel, entityType, opts, true).then((data: any) => {
        this.leads.properties = data.properties;
        this.leads.properties.entityType = entityType;
        if (!data.entities.length) return;
        this.leads.entities = this.leads.entities.concat(data.entities);
      });
    }

    showLeads(entityType: string) {
      this.showSearch = false;
      this.leads.properties.entityType = entityType;
      this.leads.properties.paging.current_page = 0;
      this.leads.entities = [];
      this.loadMore();
    }

    filter(name: string, value: any, status: any) {
      // this.leads.properties.filters['sales_status'] = null;
      // this.leads.properties.filters['data_status'] = null;
      this.activeFilter = name;

      if (name === 'days') {
        this.days = value;
        var opts = {};
        if (this.days) opts = { days: this.days };
        this.session.getEntity(SirenModel, 'user-leads_summary', opts, true).then((data: any) => {
          this.leadsSummary.properties = data.properties;
        });
      } else {
        this.leads.properties.filters[name] = value;
      }
      this.leads.properties.paging.current_page = 0;
      this.leads.entities = [];
      this.loadMore();
    }
  }

  angular
    .module('powur.grid')
    .controller(NewLeadDialogController.ControllerId, NewLeadDialogController)
    .controller(GridSolarController.ControllerId, GridSolarController)
    .controller(UpdateLeadDialogController.ControllerId, UpdateLeadDialogController);
}
