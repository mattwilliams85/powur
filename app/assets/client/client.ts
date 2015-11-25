// Bower components
// -----------------------------------------------------
//= require jquery/dist/jquery
//= require jquery-ui
//= require q/q
//= require lodash/lodash
//= require moment/moment
//= require angular/angular
//= require ngstorage/ngStorage
//= require angular-ui-router/release/angular-ui-router
//= require angular-aria/angular-aria
//= require angular-animate/angular-animate
//= require angular-material/angular-material
//= require angular-messages/angular-messages
//= require eyecue-chartjs/Chart

// NOTE: make sure to load template first
//= require angular-rails-templates

//= require layout/nav
//= require layout/hud
//= require layout/home
//= require components/activity

//= require invite/layout
//= require invite/new-invite-popup.solar
//= require invite/new-invite-popup.grid
//= require invite/show-invite-popup.solar
//= require invite/show-invite-popup.grid
//= require invite/update-invite-popup.solar
//= require invite/update-invite-popup.grid
//= require invite/invite.solar
//= require invite/invite.grid

//= require events/events

//= require login/layout
//= require login/login.public
//= require login/login.private
//= require login/forgot-password
//= require login/reset-password

//= require join/invalid
//= require join/terms
//= require join/trailer
//= require join/trailer2
//= require join/join-solar
//= require join/join-solar2
//= require join/join-solar3
//= require join/join-grid
//= require join/join-grid2
//= require app/components/assets.constant

// client / order according to any dependencies
// -----------------------------------------------------

// must be first

/// <reference path='app/models/siren.model.ts' />
/// <reference path='app/models/session.model.ts' />
/// <reference path='app/models/goals.model.ts' />
/// <reference path='app/models/invites.model.ts' />

/// <reference path='app/services/powur.services.ts' />
/// <reference path='app/services/auth-interceptor.service.ts' />
/// <reference path='app/services/session.service.ts' />
/// <reference path='app/core/powur.core.ts' />
/// <reference path='app/core/remove-extra-characters.filter.ts' />
/// <reference path='app/core/whole-number.filter.ts' />
/// <reference path='app/core/decimal-part.filter.ts' />
/// <reference path='app/core/humanize.filter.ts' />
/// <reference path='app/core/truncate-name.filter.ts' />

/// <reference path='app/components/powur.components.ts' />
/// <reference path='app/components/invite-progress.directive.ts' />
/// <reference path='app/components/scrolled.directive.ts' />
/// <reference path='app/components/title.directive.ts' />
/// <reference path='app/components/activity.controller.ts' />
/// <reference path='app/components/activity.directive.ts' />

/// <reference path='app/layout/powur.layout.ts' />
/// <reference path='app/layout/root.controller.ts' />
/// <reference path='app/layout/base.controller.ts' />
/// <reference path='app/layout/auth.controller.ts' />
/// <reference path='app/layout/home.controller.ts' />
/// <reference path='app/layout/nav.controller.ts' />
/// <reference path='app/layout/nav.directive.ts' />
/// <reference path='app/layout/hud.controller.ts' />
/// <reference path='app/layout/hud.directive.ts' />

/// <reference path='app/join/powur.join.ts' />
/// <reference path='app/join/join.solar.controller.ts' />
/// <reference path='app/join/join.grid.controller.ts' />
/// <reference path='app/join/terms.controller.ts' />

/// <reference path='app/login/powur.login.ts' />
/// <reference path='app/login/login.controller.ts' />
/// <reference path='app/login/login.public.controller.ts' />
/// <reference path='app/login/login.private.controller.ts' />

/// <reference path='app/invite/powur.invite.ts' />
/// <reference path='app/invite/invite.controller.ts' />
/// <reference path='app/invite/invite.solar.controller.ts' />
/// <reference path='app/invite/invite.grid.controller.ts' />

/// <reference path='app/events/events.controller.ts' />

/// <reference path='app/powur.module.ts' />
/// <reference path='app/powur.config.ts' />
/// <reference path='app/powur.run.ts' />
