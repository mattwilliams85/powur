;(function() {
  'use strict';

  function init($rootScope, $location, $document, $http, UserProfile) {
    $rootScope.currentUser = {};
    $rootScope.isSignedIn = !!SignedIn;
    /*
     * Fill in User object with data if user is signed in but object is empty
    */
    $rootScope.$on('$includeContentLoaded', function() {
      if ($rootScope.isSignedIn) {
        UserProfile.get().then(function(data) {
          $rootScope.currentUser = data;
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
        window.location = '/sign-in';
      }
    };

    $rootScope.foundation = function() {
      $(document).foundation();
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

    // TODO: move header functionality into its own directive
    $rootScope.signOut = function() {
      var cb = function() {
        $rootScope.isSignedIn = false;
        window.location = '/sign-in';
        // $location.path('/sign-in');
      };
      $http.delete('/login.json', {
        xsrfHeaderName: 'X-CSRF-Token'
      }).success(cb).error(cb);
    };
  }

  init.$inject = [
    '$rootScope',
    '$location',
    '$document',
    '$http',
    'UserProfile'];

  angular.module('powurApp', [
    'ngRoute',
    'ngResource',
    'fileS3Uploader'
  ]).run(init);
})();
