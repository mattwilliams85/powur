;(function() {
  'use strict';

  function config($routeProvider, $locationProvider, $sceProvider, $httpProvider) {
    $locationProvider.html5Mode(true);
    $sceProvider.enabled(false);
    $httpProvider.defaults.xsrfHeaderName = 'X-CSRF-Token';
    $httpProvider.defaults.headers.common["X-Requested-With"] = 'XMLHttpRequest';

    $routeProvider.
    when('/admin', {
      templateUrl: 'admin/landing/templates/index.html',
      controller: 'LandingCtrl'
    }).
    // Library
    when('/admin/resources', {
      templateUrl: 'admin/resources/templates/index.html',
      controller: 'AdminResourcesCtrl'
    }).
    when('/admin/resources/new/:resourceType?', {
      templateUrl: 'admin/resources/templates/new.html',
      controller: 'AdminResourcesCtrl'
    }).
    when('/admin/resources/:resourceId/edit', {
      templateUrl: 'admin/resources/templates/edit.html',
      controller: 'AdminResourcesCtrl'
    }).
    // User Groups
    when('/admin/user-groups', {
      templateUrl: 'admin/user-groups/templates/index.html',
      controller: 'AdminUserGroupsCtrl'
    }).
    when('/admin/user-groups/new', {
      templateUrl: 'admin/user-groups/templates/new.html',
      controller: 'AdminUserGroupsCtrl'
    }).
    when('/admin/user-groups/:userGroupId/edit', {
      templateUrl: 'admin/user-groups/templates/edit.html',
      controller: 'AdminUserGroupsCtrl'
    }).
    when('/admin/user-groups/:userGroupId', {
      templateUrl: 'admin/user-groups/templates/show.html',
      controller: 'AdminUserGroupsCtrl'
    }).
    // User Groups / Users
    when('/admin/user-groups/:userGroupId/users', {
      templateUrl: 'admin/user-groups/templates/users/index.html',
      controller: 'AdminUserGroupUsersCtrl'
    }).
    // User Groups / Requirements
    when('/admin/user-groups/:userGroupId/requirements', {
      templateUrl: 'admin/user-groups/templates/requirements/index.html',
      controller: 'AdminUserGroupRequirementsCtrl'
    }).
    when('/admin/user-groups/:userGroupId/requirements/new', {
      templateUrl: 'admin/user-groups/templates/requirements/new.html',
      controller: 'AdminUserGroupRequirementsCtrl'
    }).
    when('/admin/user-groups/:userGroupId/requirements/:requirementId/edit', {
      templateUrl: 'admin/user-groups/templates/requirements/edit.html',
      controller: 'AdminUserGroupRequirementsCtrl'
    }).
    // User Groups / Bonuses
    when('/admin/user-groups/:userGroupId/bonuses', {
      templateUrl: 'admin/user-groups/templates/bonuses/index.html',
      controller: 'AdminUserGroupBonusesCtrl'
    }).
    when('/admin/user-groups/:userGroupId/bonuses/new', {
      templateUrl: 'admin/user-groups/templates/bonuses/new.html',
      controller: 'AdminUserGroupBonusesCtrl'
    }).
    when('/admin/user-groups/:userGroupId/bonuses/:requirementId/edit', {
      templateUrl: 'admin/user-groups/templates/bonuses/edit.html',
      controller: 'AdminUserGroupBonusesCtrl'
    }).
    // Bonus Plans
    when('/admin/bonus-plans', {
      templateUrl: 'admin/bonus-plans/templates/index.html',
      controller: 'AdminBonusPlansCtrl'
    }).
    when('/admin/bonus-plans/new', {
      templateUrl: 'admin/bonus-plans/templates/new.html',
      controller: 'AdminBonusPlansCtrl'
    }).
    when('/admin/bonus-plans/:bonusPlanId/edit', {
      templateUrl: 'admin/bonus-plans/templates/edit.html',
      controller: 'AdminBonusPlansCtrl'
    }).
    when('/admin/bonus-plans/:bonusPlanId', {
      templateUrl: 'admin/bonus-plans/templates/show.html',
      controller: 'AdminBonusPlansCtrl'
    }).
    // Bonus Plan Bonuses
    when('/admin/bonus-plans/:bonusPlanId/bonuses', {
      templateUrl: 'admin/bonuses/templates/index.html',
      controller: 'AdminBonusesCtrl'
    }).
    when('/admin/bonus-plans/:bonusPlanId/bonuses/new', {
      templateUrl: 'admin/bonuses/templates/new.html',
      controller: 'AdminBonusesCtrl'
    }).
    when('/admin/bonus-plans/:bonusPlanId/bonuses/:bonusId/edit', {
      templateUrl: 'admin/bonuses/templates/edit.html',
      controller: 'AdminBonusesCtrl'
    }).
    // Products
    when('/admin/products', {
      templateUrl: 'admin/products/templates/index.html',
      controller: 'AdminProductsCtrl'
    }).
    when('/admin/products/new', {
      templateUrl: 'admin/products/templates/new.html',
      controller: 'AdminProductsCtrl'
    }).
    when('/admin/products/:productId', {
      templateUrl: 'admin/products/templates/show.html',
      controller: 'AdminProductsCtrl'
    }).
    when('/admin/products/:productId/edit', {
      templateUrl: 'admin/products/templates/edit.html',
      controller: 'AdminProductsCtrl'
    }).
    // Users
    when('/admin/users', {
      templateUrl: 'admin/users/templates/index.html',
      controller: 'AdminUsersCtrl'
    }).
    when('/admin/users/:userId', {
      templateUrl: 'admin/users/templates/show.html',
      controller: 'AdminUsersCtrl'
    }).
    when('/admin/users/:userId/edit', {
      templateUrl: 'admin/users/templates/edit.html',
      controller: 'AdminUsersCtrl'
    }).
    // Quotes
    when('/admin/quotes', {
      templateUrl: 'admin/quotes/templates/index.html',
      controller: 'AdminQuotesCtrl'
    }).
    when('/admin/quotes/:quoteId', {
      templateUrl: 'admin/quotes/templates/show.html',
      controller: 'AdminQuotesCtrl'
    }).
    when('/admin/quotes/:quoteId/edit', {
      templateUrl: 'admin/quotes/templates/edit.html',
      controller: 'AdminQuotesCtrl'
    }).
    // Orders
    when('/admin/orders', {
      templateUrl: 'admin/orders/templates/index.html',
      controller: 'AdminOrdersCtrl'
    }).
    when('/admin/orders/:orderId', {
      templateUrl: 'admin/orders/templates/show.html',
      controller: 'AdminOrdersCtrl'
    }).
    when('/admin/orders/:orderId/edit', {
      templateUrl: 'admin/orders/templates/edit.html',
      controller: 'AdminOrdersCtrl'
    }).
    // Pay Periods
    when('/admin/pay-periods', {
      templateUrl: 'admin/pay-periods/templates/index.html',
      controller: 'AdminPayPeriodsCtrl'
    }).
    when('/admin/pay-periods/:payPeriodId', {
      templateUrl: 'admin/pay-periods/templates/show.html',
      controller: 'AdminPayPeriodsCtrl'
    }).
    when('/admin/pay-periods/:payPeriodId/edit', {
      templateUrl: 'admin/pay-periods/templates/edit.html',
      controller: 'AdminPayPeriodsCtrl'
    }).
    // Dashboard Notifications
    when('/admin/notifications', {
      templateUrl: 'admin/notifications/templates/index.html',
      controller: 'AdminNotificationsCtrl'
    }).
    when('/admin/notifications/new', {
      templateUrl: 'admin/notifications/templates/new.html',
      controller: 'AdminNotificationsCtrl'
    }).
    when('/admin/notifications/:notificationId/edit', {
      templateUrl: 'admin/notifications/templates/edit.html',
      controller: 'AdminNotificationsCtrl'
    }).
    // Social Media Sharing
    when('/admin/social-media', {
      templateUrl: 'admin/social-media/templates/index.html',
      controller: 'AdminSocialMediaCtrl'
    }).
    when('/admin/social-media/:socialMediaPostId', {
      templateUrl: 'admin/social-media/templates/show.html',
      controller: 'AdminSocialMediaCtrl'
    }).
    when('/admin/social-media/:socialMediaPostId/edit', {
      templateUrl: 'admin/social-media/templates/edit.html',
      controller: 'AdminSocialMediaCtrl'
    }).

    otherwise({
      redirectTo: '/admin'
    });
  }

  config.$inject = [
    '$routeProvider',
    '$locationProvider',
    '$sceProvider',
    '$httpProvider'];

  angular.module('powurApp').config(config);
})();
