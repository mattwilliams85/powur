/// <reference path='../../typings/tsd.d.ts' />

module powur {
  'use strict';

  class TermsDialogController {
    static ControllerId = 'TermsDialogController';
    static $inject = ['$log', '$mdDialog'];

    constructor(private $log: ng.ILogService, private $mdDialog: ng.material.IDialogService) {
      this.$log.debug(TermsDialogController.ControllerId + ':ctor');
    }

    ok() {
      this.$mdDialog.hide();
    }
  }

  angular
    .module('powur.join')
    .controller(TermsDialogController.ControllerId, TermsDialogController);
}
