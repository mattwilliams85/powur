// Bower components
// -----------------------------------------------------
//= require jquery/dist/jquery
//= require jquery-ui
//= require velocity/test/q
//= require lodash/lodash
//= require moment/moment
//= require angular/angular
//= require ngstorage/ngStorage
//= require angular-ui-router/release/angular-ui-router
//= require angular-aria/angular-aria
//= require angular-animate/angular-animate
//= require angular-material/angular-material
//= require angular-messages/angular-messages

// NOTE: make sure to load template first
//= require angular-rails-templates

//= require components/nav
//= require components/activity
//= require components/hud

//= require home/home
//= require invite/layout
//= require invite/new-invite-popup.solar
//= require invite/new-invite-popup.grid
//= require invite/invite.product
//= require invite/invite.grid
//= require events/events

//= require login/layout
//= require login/login.public
//= require login/login.private
//= require login/forgot-password

//= require join/invalid
//= require join/terms
//= require join/join-solar
//= require join/join-solar2
//= require join/join-solar3
//= require join/join-grid
//= require join/join-grid2

// client / order according to any dependencies
// -----------------------------------------------------
// must be first
/// <reference path='app/client.config.ts' />
/// <reference path='app/client.run.ts' />
/// <reference path='app/client.module.ts' />

/// <reference path='app/models/siren.model.ts' />
/// <reference path='app/models/session.model.ts' />
/// <reference path='app/models/goals.model.ts' />
/// <reference path='app/models/invites.model.ts' />

/// <reference path='app/services/cache.service.ts' />
/// <reference path='app/services/auth-interceptor.service.ts' />
/// <reference path='app/services/data.service.ts' />
/// <reference path='app/services/session.service.ts' />

/// <reference path='app/filters/whole-number.filter.ts' />
/// <reference path='app/filters/decimal-part.filter.ts' />
/// <reference path='app/filters/humanize.filter.ts' />
/// <reference path='app/components/invite-progress.directive.ts' />
/// <reference path='app/components/nav.controller.ts' />
/// <reference path='app/components/nav.directive.ts' />
/// <reference path='app/components/activity.controller.ts' />
/// <reference path='app/components/activity.directive.ts' />
/// <reference path='app/components/hud.controller.ts' />
/// <reference path='app/components/hud.directive.ts' />

/// <reference path='app/layout/base.controller.ts' />
/// <reference path='app/layout/auth.controller.ts' />
/// <reference path='app/layout/root.controller.ts' />

/// <reference path='app/home/home.controller.ts' />
/// <reference path='app/invite/invite.controller.ts' />
/// <reference path='app/invite/invite.product.controller.ts' />
/// <reference path='app/invite/invite.grid.controller.ts' />
/// <reference path='app/events/events.controller.ts' />

/// <reference path='app/login/login.controller.ts' />
/// <reference path='app/login/login.public.controller.ts' />
/// <reference path='app/login/login.private.controller.ts' />

/// <reference path='app/join/terms.controller.ts' />
/// <reference path='app/join/join.solar.controller.ts' />
/// <reference path='app/join/join.grid.controller.ts' />


// must be last
/// <reference path='app/client.config.ts' />
/// <reference path='app/client.run.ts' />
