;(function() {
  'use strict';

  function init($rootScope, $location, $document, $http, $window, $timeout, UserProfile) {
    $rootScope.currentUser = {};
    $rootScope.isSignedIn = !!SignedIn;

    //Temp fix for sizzle selector bug
    Object.getPrototypeOf(document.createComment('')).getAttribute = function() {}

    $rootScope.redirectIfSignedIn = function() {
      if ($rootScope.isSignedIn) {
        if ($rootScope.redirectAfterSignIn) {
          $location.path($rootScope.redirectAfterSignIn.destination);
        } else if ($rootScope.currentUser.latest_terms) {
          $location.path('/latest-terms');
        } else {
          $location.path('/dashboard');
        }
      }
      return;
    };

    $rootScope.redirectUnlessSignedIn = function() {
      if (!$rootScope.isSignedIn) {
        $location.path('/sign-in');
      } else {
        if ($rootScope.currentUser.latest_terms) {
          $location.path('/latest-terms');
        }
      }
    };

    // Redirect to '/latest-terms' if currentUser object contains latest_terms property
    $rootScope.$watch('currentUser', function(data) {
      if ($rootScope.currentUser.latest_terms) {
        $location.path('/latest-terms');
      }
    });


    $rootScope.animateArrow = function(id, time) {
      $timeout.cancel(pilerTimer);
      var element = $('.arrow-box')[id-1];
      var pilerTimer = $timeout(function() {
        $(element).show().animate({
          bottom: '20px'
        }, 500, 'easeOutBounce');
      }, time);

      $rootScope.$on('$locationChangeStart', function() {
        $timeout.cancel(pilerTimer);
      });
    };

    $rootScope.showModal = function(text, modalClass) {
      modalClass = modalClass || '';
      var domElement =
        '<div class=\'reveal-modal ' + modalClass + '\' data-reveal>' +
        '<h3>' + text + '</h3>' +
        '<a class=\'close-reveal-modal\'>&#215;</a>' +
        '</div>';
      $(domElement).foundation('reveal', 'open');
    };

    $rootScope.enableScrollDetect = function() {
      $(window).on('scroll', function () {
        var screenHeight = $(window).height() - ($(window).height() / 1.4);
        var scrollPos = $(window).scrollTop();
        if ($('.pow-header-guest').hasClass('velocity-animating')) return;
        if (scrollPos < screenHeight && $('.pow-header-guest').hasClass('invert')) {
          $('.pow-header-guest').velocity('transition.slideUpBigOut', function() {
            $('.pow-header-guest').toggleClass('invert').show().velocity({ opacity: 1 }, 200);
          });
        }
        if (scrollPos > screenHeight && !$('.pow-header-guest').hasClass('invert')) {
          $('.pow-header-guest').toggleClass('invert').velocity('transition.slideDownBigIn');
        }
      });
    };

    $rootScope.isMenuLinkActive = function(path) {
      if (path === $location.path()) return true;
      return false;
    };

    $rootScope.isMobile = function() {
      if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
       return true;
      }
    }

    $rootScope.signOut = function() {
      var cb = function() {
        SignedIn = false;
        $rootScope.isSignedIn = false;
        $rootScope.currentUser = {};
        // window.location = '#/sign-in';
        $location.path('/sign-in');
      };
      UserProfile.signOut().then(cb, cb);
    };

    $rootScope.gotoAnchor = function(id) {
      if (id === 'dim_the_lights') $('body').css('background','#111');
      var duration = 500;
      var offset = 0; // pixels; adjust for floating menu, context etc
      // Scroll to #some-id with N px 'padding'
      $('.pow-bg-1').animate({ opacity: '0' }, 700, function() {
        var someElement = angular.element(document.getElementById(id));
        $document.scrollToElement(someElement, offset, duration);
        setTimeout(function(){
          $('body').css('background','transparent');
          //prevents users from getting stuck on second slide
          if (id === 'dim_the_lights') {
            $('.pow-bg-1').hide();
            $('body,html').scrollTop(0);
          }
          if (id === 'on_slider_move') {
            // $('body').css('background','transparent')
            $('.pow-bg-1').css('opacity','1').show();
            $(window).scrollTop($('.pow-promo-slide-3').offset().top);
            if ($('body').css('overflow') !== 'visible') {
              $('body').css('overflow','visible');
              $('.pow-header-guest').toggleClass('invert').velocity('transition.slideDownBigIn');
              $rootScope.enableScrollDetect();
            }
          }
        }, 700);
      });
    };

  }

  init.$inject = [
    '$rootScope',
    '$location',
    '$document',
    '$http',
    '$window',
    '$timeout',
    'UserProfile'];

  angular.module('powurApp', [
    'ngRoute',
    'ngResource',
    'uiSlider',
    'duScroll',
    'angularS3FileUpload',
    'blocks.filters',
    'app.widgets',
    'templates'
  ]).run(init);

})();
