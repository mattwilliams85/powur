/// <reference path='../_references.ts' />

module powur {
  'use strict';

  class LoginController extends BaseController {
    static ControllerId = 'LoginController';

    get create(): Action {
      return this.session.action('create');
    }

    constructor($state: ng.ui.IStateService,
                $session: ISessionService) {
      super($state, $session);

      if (!this.session.loggedIn()) {
        this.create.success = this.success;
        this.create.fail = this.fail;
      }
    }

    success = (response: ng.IHttpPromiseCallbackArg<any>): void => {
      console.log('woot!');
    }

    fail = (response: ng.IHttpPromiseCallbackArg<any>): void => {
      console.log('fail!', this);
    }
  }

  controllerModule.controller(LoginController.ControllerId, LoginController);
}


// module powur {
//   'use strict';

//   class LoginController {
//     static ControllerId = 'LoginController';
//     static $inject = ['$scope', '$state', 'SessionService'];

//     session: ISessionModel;

//     get create(): Action {
//       return this.session.action("create");
//     }

//     constructor(private $scope: any,
//           private $state: ng.ui.IStateService,
//           private sessionService: ISessionService) {

//       this.session = sessionService.session;

//       if (!this.session.loggedIn()) {
//         this.create.success = this.success;
//         this.create.fail = this.fail;
//       }
//     }

//     success(response: ng.IHttpPromiseCallbackArg<any>) {
//       console.log('woot!');
//     }

//     fail(response: ng.IHttpPromiseCallbackArg<any>) {
//       console.log("fail!");
//     }
//   }

//   controllerModule.controller(LoginController.ControllerId, LoginController);
// }
