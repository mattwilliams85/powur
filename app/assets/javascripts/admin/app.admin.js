;(function() {
  'use strict';

  function init($rootScope, $location, $document, $http, $timeout, $mdSidenav, UserProfile) {
    $rootScope.currentUser = {};
    $rootScope.isSignedIn = !!SignedIn;
    $rootScope.menu = {};
    $rootScope.legacyImagePaths = legacyImagePaths;
    /*
     * Fill in User object with data if user is signed in but object is empty
    */
    $rootScope.$on('$includeContentLoaded', function() {
      if ($rootScope.isSignedIn) {
        UserProfile.get().then(function(data) {
          $rootScope.currentUser = data.properties;
        });
      }
    });

    $rootScope.redirectToDashboardIfSignedIn = function() {
      if ($rootScope.isSignedIn) {
        window.location = '/dashboard';
      }
    };

    $rootScope.redirectUnlessSignedIn = function() {
      if (!$rootScope.isSignedIn) {
        window.location = '/';
      }
    };

    $rootScope.states = {
        'Alabama': 'Alabama',
        'Alaska': 'Alaska',
        'Arizona': 'Arizona',
        'Arkansas': 'Arkansas',
        'California': 'California',
        'Colorado': 'Colorado',
        'Connecticut': 'Connecticut',
        'Delaware': 'Delaware',
        'Florida': 'Florida',
        'Georgia': 'Georgia',
        'Hawaii': 'Hawaii',
        'Idaho': 'Idaho',
        'Illinois': 'Illinois',
        'Indiana': 'Indiana',
        'Iowa': 'Iowa',
        'Kansas': 'Kansas',
        'Kentucky': 'Kentucky',
        'Louisiana': 'Louisiana',
        'Maine': 'Maine',
        'Maryland': 'Maryland',
        'Massachusetts': 'Massachusetts',
        'Michigan': 'Michigan',
        'Minnesota': 'Minnesota',
        'Mississippi': 'Mississippi',
        'Missouri': 'Missouri',
        'Montana': 'Montana',
        'Nebraska': 'Nebraska',
        'Nevada': 'Nevada',
        'New Hampshire': 'New Hampshire',
        'New Jersey': 'New Jersey',
        'New Mexico': 'New Mexico',
        'New York': 'New York',
        'North Carolina': 'North Carolina',
        'North Dakota': 'North Dakota',
        'Ohio': 'Ohio',
        'Oklahoma': 'Oklahoma',
        'Oregon': 'Oregon',
        'Pennsylvania': 'Pennsylvania',
        'Rhode Island': 'Rhode Island',
        'South Carolina': 'South Carolina',
        'South Dakota': 'South Dakota',
        'Tennessee': 'Tennessee',
        'Texas': 'Texas',
        'Utah': 'Utah',
        'Vermont': 'Vermont',
        'Virginia': 'Virginia',
        'Washington': 'Washington',
        'West Virginia': 'West Virginia',
        'Wisconsin': 'Wisconsin',
        'Wyoming': 'Wyoming'
    };

    // Breadcrumbs for navigation
    $rootScope.$on('$locationChangeStart', function() {
      $rootScope.breadcrumbs = [{title: 'Administration', href: '/admin'}];
    });

    $rootScope.showModal = function(text, modalClass) {
      modalClass = modalClass || '';
      $('<div class=\'reveal-modal ' + modalClass + '\' data-reveal><h3>' + text + '</h3><a class=\'close-reveal-modal\'>&#215;</a></div>').foundation('reveal', 'open');
    };

    $rootScope.isMenuLinkActive = function(path) {
      if (path === $location.path()) return true;
      return false;
    };


    $rootScope.isRouteAdmin = function() {
      if (/\/admin$/.test($location.path())) return true;
    };

    $rootScope.menuPosition = function(e, active) {
      $rootScope.menu.active = active;
      if (!$(e.target).hasClass('menu-item')) return;
      var offset = e.target.offsetTop;
      var height = ($(e.target).find('.sub-menu').children().length * 42) - 59;

      if (height + offset < window.innerHeight) {
        $rootScope.menu.top = offset
      } else {
        $rootScope.menu.top = offset - height;
      }
    };

    $rootScope.signOut = function() {
      $http.delete('/login.json').success(function() {
        window.location = '/';
      });
    };

    $rootScope.openMenu = function() {
      $mdSidenav('mobile-left').toggle();
    };
  }

  init.$inject = [
    '$rootScope',
    '$location',
    '$document',
    '$http',
    '$timeout',
    '$mdSidenav',
    'UserProfile'];

  angular.module('powurApp', [
    'ngRoute',
    'ngResource',
    'angularS3FileUpload',
    'blocks.filters',
    'app.admin.widgets',
    'templates',
    'ngAnimate',
    'ngMaterial'
  ]).run(init);
})();
