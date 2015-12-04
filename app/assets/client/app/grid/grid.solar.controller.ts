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

    create() {
      this.createAction.submit().then((response: ng.IHttpPromiseCallbackArg<any>) => {
        this.lead = new SirenModel(response.data);
      });
    }

    update() {
      this.updateAction.submit().then((response: ng.IHttpPromiseCallbackArg<any>) => {
        this.lead = new SirenModel(response.data);

        this.submitAction.submit().then((response: ng.IHttpPromiseCallbackArg<any>) => {
          this.$mdDialog.cancel();
        }, (response: any) => {
          if (response.data.error) {
            this.updateAction.field('notes').$error = { message: response.data.error.message };
          }
        });
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

          // this.lead.entity('invite-email').get((email_data: any) => {
          //   this.lead.properties.email_data = email_data.properties;
          // });
        }
      }

      remove() {
        this.delete.submit().then((response: ng.IHttpPromiseCallbackArg<any>) => {
          delete this.lead;
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
          this.$mdDialog.hide(response.data);
        });
      }

      showLink(customer): string {
        return 'https://powur.com/next/join/grid/' + customer.id;
      }

      cancel() {
        this.$mdDialog.cancel();
      }

      get delete(): Action { return this.lead.action('delete') }
      get resend(): Action { return this.lead.action('resend') }
      get update(): Action { return this.lead.action('update') }
      get customer(): any  { return this.lead.properties.customer }
  }

  class GridSolarController extends AuthController {
    static ControllerId = 'GridSolarController';
    static $inject = ['leadsSummary', 'leads', '$mdDialog', '$timeout'];

    days: number = 60;
    searchQuery: string;
    showSearch: boolean;
    stage: string[] = ['submit', 'qualify', 'closed won', 'contract', 'install']; 

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

    leadStage(lead) {
      if (lead.properties.installed_at)  { return 5; }
      if (lead.properties.contracted_at) { return 4; }
      if (lead.properties.closed_won_at) { return 3; }
      if (lead.properties.converted_at)  { return 2; }
      if (lead.properties.submitted_at)  { return 1; }
      return 0;
    };
    
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
        }).then((data: any) => {
          // if (data) this.leads = new SirenModel(data);
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
        // if (data) this.leads.entities = new SirenModel(data).entities;
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

    filter(name: string, value: any) {
      if (name === 'days') {
        this.days = value;
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
