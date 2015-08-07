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
    // Application and Agreements
    when('/admin/application-agreements', {
      templateUrl: 'shared/admin/rest/index.html',
      controller: 'AdminApplicationAgreementsCtrl'
    }).
    when('/admin/application-agreements/new', {
      templateUrl: 'shared/admin/rest/new.html',
      controller: 'AdminApplicationAgreementsCtrl'
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
    // Invites
    when('/admin/invites', {
      templateUrl: 'admin/invites/templates/index.html',
      controller: 'AdminInvitesCtrl'
    }).
    // Latest News
    when('/admin/latest-news', {
      templateUrl: 'shared/admin/rest/index.html',
      controller: 'AdminLatestNewsCtrl'
    }).
    when('/admin/latest-news/new', {
      templateUrl: 'shared/admin/rest/new.html',
      controller: 'AdminLatestNewsCtrl'
    }).
    when('/admin/latest-news/:newsPostId/edit', {
      templateUrl: 'shared/admin/rest/edit.html',
      controller: 'AdminLatestNewsCtrl'
    }).
    // Notifications
    when('/admin/notifications', {
      templateUrl: 'shared/admin/rest/index.html',
      controller: 'AdminNotificationsCtrl'
    }).
    when('/admin/notifications/new', {
      templateUrl: 'shared/admin/rest/new.html',
      controller: 'AdminNotificationsCtrl'
    }).
    when('/admin/notifications/:notificationId/edit', {
      templateUrl: 'shared/admin/rest/edit.html',
      controller: 'AdminNotificationsCtrl'
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
    // Products
    when('/admin/products', {
      templateUrl: 'shared/admin/rest/index.html',
      controller: 'AdminProductsCtrl'
    }).
    when('/admin/products/new', {
      templateUrl: 'shared/admin/rest/new.html',
      controller: 'AdminProductsCtrl'
    }).
    when('/admin/products/:productId/edit', {
      templateUrl: 'shared/admin/rest/edit.html',
      controller: 'AdminProductsCtrl'
    }).
    // Product Enrollments
    when('/admin/product_enrollments', {
      templateUrl: 'shared/admin/rest/index.html',
      controller: 'AdminProductEnrollmentsCtrl'
    }).
    // Product Receipts
    when('/admin/product_receipts', {
      templateUrl: 'shared/admin/rest/index.html',
      controller: 'AdminProductReceiptsCtrl'
    }).
    // Propsoals
    when('/admin/proposals', {
      templateUrl: 'admin/proposals/templates/index.html',
      controller: 'AdminProposalsCtrl'
    }).
    when('/admin/proposals/:proposalId', {
      templateUrl: 'admin/proposals/templates/show.html',
      controller: 'AdminProposalsCtrl'
    }).
    when('/admin/proposals/:proposalId/edit', {
      templateUrl: 'admin/proposals/templates/edit.html',
      controller: 'AdminProposalsCtrl'
    }).
    // Library
    when('/admin/resources', {
      templateUrl: 'shared/admin/rest/index.html',
      controller: 'AdminResourcesCtrl'
    }).
    when('/admin/resources/new/:resourceType?', {
      templateUrl: 'shared/admin/rest/new.html',
      controller: 'AdminResourcesCtrl'
    }).
    when('/admin/resources/:resourceId/edit', {
      templateUrl: 'shared/admin/rest/edit.html',
      controller: 'AdminResourcesCtrl'
    }).
    // Library Topics
    when('/admin/resource-topics', {
      templateUrl: 'shared/admin/rest/index.html',
      controller: 'AdminResourceTopicsCtrl'
    }).
    when('/admin/resource-topics/new', {
      templateUrl: 'shared/admin/rest/new.html',
      controller: 'AdminResourceTopicsCtrl'
    }).
    when('/admin/resource-topics/:topicId/edit', {
      templateUrl: 'shared/admin/rest/edit.html',
      controller: 'AdminResourceTopicsCtrl'
    }).
    // Social Media Sharing
    when('/admin/social-media', {
      templateUrl: 'shared/admin/rest/index.html',
      controller: 'AdminSocialMediaCtrl'
    }).
    when('/admin/social-media/:socialMediaPostId/edit', {
      templateUrl: 'shared/admin/rest/edit.html',
      controller: 'AdminSocialMediaCtrl'
    }).
    when('/admin/social-media/new', {
      templateUrl: 'shared/admin/rest/new.html',
      controller: 'AdminSocialMediaCtrl'
    }).
    // System Settings
    when('/admin/system-settings', {
      templateUrl: 'shared/admin/rest/index.html',
      controller: 'AdminSystemSettingsCtrl'
    }).
    when('/admin/system-settings/:settingId/edit', {
      templateUrl: 'shared/admin/rest/edit.html',
      controller: 'AdminSystemSettingsCtrl'
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
    when('/admin/users/:userId/edit_password', {
      templateUrl: 'admin/users/templates/edit_password.html',
      controller: 'AdminUsersCtrl'
    }).
    when('/admin/users/:userId/place-user', {
      templateUrl: 'admin/users/templates/place-user.html',
      controller: 'AdminUsersCtrl'
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
