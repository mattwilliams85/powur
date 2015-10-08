// Bower components
// -----------------------------------------------------
//= require jquery/dist/jquery
//= require velocity/test/q
//= require lodash/lodash
//= require moment/moment
//= require angular/angular
//= require ngstorage/ngStorage
//= require angular-ui-router/release/angular-ui-router
//= require angular-aria/angular-aria
//= require angular-animate/angular-animate
//= require angular-material/angular-material

// NOTE: make sure to load template first
//= require angular-rails-templates

//= require components/nav
//= require components/activity
//= require components/hud

//= require home/home
//= require invite/invite
//= require invite/invite-popup
//= require events/events

//= require login/login

//= require join/terms
//= require join/join-solar
//= require join/join-solar2
//= require join/join-solar3
//= require join/join-grid
//= require join/join-grid2

// client / order according to any dependencies
// -----------------------------------------------------
// must be first
/// <reference path='client.module.ts' />

/// <reference path='services/cache.service.ts' />
/// <reference path='services/auth-interceptor.service.ts' />
/// <reference path='services/data.service.ts' />

/// <reference path='filters/whole-number.filter.ts' />
/// <reference path='filters/decimal-part.filter.ts' />
/// <reference path='filters/humanize.filter.ts' />
/// <reference path='components/invite-progress.directive.ts' />
/// <reference path='components/nav.controller.ts' />
/// <reference path='components/nav.directive.ts' />
/// <reference path='components/activity.controller.ts' />
/// <reference path='components/activity.directive.ts' />
/// <reference path='components/hud.controller.ts' />
/// <reference path='components/hud.directive.ts' />

/// <reference path='layout/root.controller.ts' />

/// <reference path='home/home.controller.ts' />
/// <reference path='invite/invite.controller.ts' />
/// <reference path='events/events.controller.ts' />

/// <reference path='login/login.controller.ts' />

/// <reference path='join/terms.controller.ts' />
/// <reference path='join/join.controller.ts' />

// must be last
/// <reference path='client.routes.ts' />
/// <reference path='client.config.ts' />
