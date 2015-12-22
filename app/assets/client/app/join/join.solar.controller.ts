/// <reference path='../layout/base.controller.ts' />

module powur {
  'use strict';

  class JoinSolarController extends BaseController {
    static ControllerId = 'JoinSolarController';
    static $inject = ['$stateParams', 'customer'];

    constructor(private $stateParams: ng.ui.IStateParamsService,
                private customer: ISirenModel) {
      super();

      if (this.customer) {
        this.state.go('landing', {
          repId: this.customer.properties.owner.id,
          inviteCode: this.$stateParams['inviteCode'] });
      }
    }
  }

  angular
    .module('powur.join')
    .controller(JoinSolarController.ControllerId, JoinSolarController);
}
