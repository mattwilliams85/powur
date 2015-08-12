;(function() {
  'use strict';

  function config($routeProvider, $locationProvider, $sceProvider, $httpProvider) {
    $locationProvider.html5Mode(true);
    $sceProvider.enabled(false);
    $httpProvider.defaults.xsrfHeaderName = 'X-CSRF-Token';
    $httpProvider.defaults.headers.common["X-Requested-With"] = 'XMLHttpRequest';

    $routeProvider.
    when('/home', {
      templateUrl: 'landing/templates/index.html',
      controller: 'LandingCtrl'
    }).
    when('/dashboard', {
      templateUrl: 'dashboard/templates/index.html',
      controller: 'DashboardCtrl'
    }).
    when('/sign-in', {
      templateUrl: 'landing/templates/sign-in.html',
      controller: 'LandingCtrl'
    }).
    when('/forgot-password', {
      templateUrl: 'landing/templates/forgot-password.html',
      controller: 'LandingCtrl'
    }).
    when('/reset-password/:resetPasswordToken', {
      templateUrl: 'landing/templates/reset-password.html',
      controller: 'LandingCtrl'
    }).
    // Sign Up
    when('/sign-up/:inviteCode?', {
      templateUrl: 'sign-up/templates/index.html',
      controller: 'SignUpCtrl'
    }).

    // Latest Terms of Service
    when('/latest-terms', {
      templateUrl: 'latest-terms/templates/index.html',
      controller: 'LatestTermsCtrl'
    }).

    // Mobile Proposal Entry
    when('/qualify', {
      templateUrl: 'qualify/templates/index.html',
      controller: 'QualifyCtrl'
    }).

    // FAQ
    when('/customer-faq', {
      templateUrl: 'user-static-content/templates/customer-faq.html',
      controller: 'UserStaticContentCtrl'
    }).
    when('/advocate-faq', {
      templateUrl: 'user-static-content/templates/advocate-faq.html',
      controller: 'UserStaticContentCtrl'
    }).

    //Webinar
    when('/preview', {
      templateUrl: 'user-static-content/templates/preview.html',
      controller: 'UserStaticContentCtrl'
    }).

    //Leaderboard
    when('/leaderboard', {
      templateUrl: 'leaderboard/templates/index.html',
      controller: 'LeaderboardCtrl'
    }).

    // Promo
    when('/create-wealth/:inviteCode', {
      templateUrl: 'sign-up/templates/index.html',
      controller: 'SignUpCtrl'
    }).
    when('/create-wealth', {
      templateUrl: 'promo/templates/create-wealth.html',
      controller: 'PromoCtrl'
    }).
    when('/create-energy', {
      templateUrl: 'promo/templates/create-energy.html',
      controller: 'PromoCtrl'
    }).
    when('/why-solar', {
      templateUrl: 'promo/templates/why-solar.html',
      controller: 'PromoCtrl'
    }).
    when('/why-you', {
      templateUrl: 'promo/templates/why-you.html',
      controller: 'PromoCtrl'
    }).
    when('/why-direct-marketing', {
      templateUrl: 'promo/templates/why-direct-marketing.html',
      controller: 'PromoCtrl'
    }).
    when('/why-powur', {
      templateUrl: 'promo/templates/why-powur.html',
      controller: 'PromoCtrl'
    }).
    when('/our-origin', {
      templateUrl: 'promo/templates/our-origin.html',
      controller: 'PromoCtrl'
    }).
    when('/our-team', {
      templateUrl: 'promo/templates/our-team.html',
      controller: 'PromoCtrl'
    }).
    when('/our-dna', {
      templateUrl: 'promo/templates/our-dna.html',
      controller: 'PromoCtrl'
    }).

    // University
    when('/university', {
      templateUrl: 'university/templates/index.html',
      controller: 'UniversityCtrl'
    }).

    // Memberships
    when('/upgrade', {
      templateUrl: 'memberships/templates/index.html',
      controller: 'MembershipsCtrl'
    }).

    // Library
    when('/library', {
      templateUrl: 'library/templates/index.html',
      controller: 'LibraryCtrl'
    }).

    // Earnings
    when('/earnings', {
      templateUrl: 'earnings/templates/index.html',
      controller: 'EarningsCtrl'
    }).

    when('/terms-of-service', {
      templateUrl: 'user-static-content/templates/terms-of-service.html',
      controller: 'UserStaticContentCtrl'
    }).
    when('/terms-of-purchase', {
      templateUrl: 'user-static-content/templates/terms-of-purchase.html',
      controller: 'UserStaticContentCtrl'
    }).
    when('/privacy-policy', {
      templateUrl: 'user-static-content/templates/privacy-policy.html',
      controller: 'UserStaticContentCtrl'
    }).
    when('/disclaimer', {
      templateUrl: 'user-static-content/templates/disclaimer.html',
      controller: 'UserStaticContentCtrl'
    }).
    when('/contact', {
      templateUrl: 'user-static-content/templates/contact.html',
      controller: 'UserStaticContentCtrl'
    }).

    // User's Profile page
    when('/profile', {
      templateUrl: 'profile/templates/edit.html',
      controller: 'ProfileCtrl'
    }).

    otherwise({
      redirectTo: '/home'
    });
  }

  config.$inject = [
    '$routeProvider',
    '$locationProvider',
    '$sceProvider',
    '$httpProvider'];

  angular.module('powurApp').config(config);

})();
