// Admin App JS files

/*
 * Bower components
 */
//= require jquery/dist/jquery
//= require jquery-ui/ui/jquery-ui
//= require foundation/js/foundation
//= require angular/angular
//= require angular-route/angular-route
//= require angular-resource/angular-resource
//= require angular-scroll/angular-scroll

// TODO: this block of js libraries is still in the repo,
// need to either remove or request from bower
//
//= require admin/vendor/Autolinker.min

/*
 * App js resources
 */
//= require ./admin/app.admin
//= require ./admin/app.admin.routes
//= require_tree ./admin/bonus
//= require_tree ./admin/bonus-plans
//= require_tree ./admin/landing
//= require_tree ./admin/notifications
//= require_tree ./admin/orders
//= require_tree ./admin/pay-periods
//= require_tree ./admin/products
//= require_tree ./admin/quotes
//= require_tree ./admin/resources
//= require_tree ./admin/social-media
//= require_tree ./admin/user-groups
//= require_tree ./admin/users
//
//= require_tree ./profile
//= require_tree ./file-s3-uploader

$(document).foundation();
