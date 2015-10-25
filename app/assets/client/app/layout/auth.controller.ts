/// <reference path='../_references.ts' />

module powur {
  'use strict';

  export class AuthController extends BaseController {
    get userData(): any {
      return this.root.$session.properties;
    }
  }
}
