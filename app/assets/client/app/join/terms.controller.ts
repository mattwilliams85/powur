/// <reference path='../_references.ts' />

module powur {
  class TermsDialogController {
    static ControllerId: string = 'TermsDialogController';
    static $inject: Array<string> = ['$log', '$mdDialog'];

    constructor(private $log: ng.ILogService, private $mdDialog: ng.material.IDialogService) {
      this.$log.debug(TermsDialogController.ControllerId + ':ctor');
    }

    ok() {
      this.$mdDialog.hide();
    }
  }

  controllerModule.controller(TermsDialogController.ControllerId, TermsDialogController);
}
