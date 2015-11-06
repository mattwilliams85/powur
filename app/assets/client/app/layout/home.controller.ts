/// <reference path='../layout/auth.controller.ts' />

module powur {
  'use strict';

  class HomeController extends AuthController {
    static ControllerId = 'HomeController';
    static $inject = ['$mdSidenav', 'goals', 'requirements'];

    get userData(): any {
      return this.session.properties;
    }
    
    constructor(private $mdSidenav: ng.material.ISidenavService,
                public goals: GoalsModel,
                public requirements: ISirenModel) {
      super();
    }
    
  }

  angular
    .module('powur.layout')
    .controller(HomeController.ControllerId, HomeController);
}