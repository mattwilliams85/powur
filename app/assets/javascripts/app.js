'use strict';

var powurApp = angular.module('powurApp', [
  'ngRoute',

  'sunstandControllers',
  'sunstandServices',

  // Directives
  'sunstandApp.fileS3Uploader'
]).run(['$rootScope', '$location', '$document', '$http', '$window', '$timeout',
  function ($rootScope, $location, $document, $http, $window, $timeout) {
    $rootScope.currentUser = {};
    $rootScope.isSignedIn = !!SignedIn;
    $rootScope.enrollmentRequirementMessage =
      'Unlock your Powur dashboard by passing the F.I.T test in Powur U.';

    // Initialize Foundation JS on page load
    $timeout(function() {
      $(document).foundation();
    }, 1000);

    $rootScope.redirectIfSignedIn = function() {
      if (!$rootScope.isSignedIn) return;

      if ($rootScope.currentUser && $rootScope.currentUser.require_enrollment) {
        $location.path('/university');
        $rootScope.showModal($rootScope.enrollmentRequirementMessage);
      } else {
        $location.path('/dashboard');
      }
    };

    $rootScope.redirectUnlessSignedIn = function() {
      if (!$rootScope.isSignedIn) {
        $location.path('/sign-in');
      }
    };

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

    $rootScope.removePiler = function(){
      $('html').removeClass('piling-on');
      $('body').removeClass('no-scroll');
      $('#pp-nav').remove();
    };

    $rootScope.readyPiler = function(){
      $('html').addClass('piling-on');
      setTimeout(function() {
        $rootScope.pagePiler();
      }, 10);
    };

    $rootScope.pagePiler = function() {
      if($('#pagepiling').length === 0) return;

      $('.fa-chevron-down, .bulb-btn, .watch').click(function(e){
           e.preventDefault();
           $.fn.pagepiling.moveSectionDown();
           e.stopPropagation();         
       });

      $('#pagepiling').pagepiling({
        menu: null,
        direction: 'vertical',
        verticalCentered: true,
        sectionsColor: [],
        anchors: [],
        scrollingSpeed: 700,
        easing: 'swing',
        loopBottom: false,
        loopTop: false,
        css3: true,
        navigation: {
          'textColor': '#fff',
          'bulletsColor': '#333',
          'position': 'right',
          'tooltips': ''
        },
        normalScrollElements: null,
        normalScrollElementTouchThreshold: 5,
        touchSensitivity: 5,
        keyboardScrolling: true,
        sectionSelector: '.section',
        animateAnchor: false,
        //events
        onLeave: function(index, nextIndex) {
          changeNavColor();
          $rootScope.animateArrow(nextIndex,1800);
          $rootScope.nextIndex = nextIndex;
          $timeout(function() {
            if (nextIndex === 1) {
              $('.sun-header-guest').velocity('transition.slideUpBigOut', function() {
                $('.sun-header-guest').toggleClass('invert').show().velocity({ opacity: 1 }, 200);
              });
            }
            if (nextIndex > 1 && !$('.sun-header-guest').hasClass('invert')) { $('.sun-header-guest').toggleClass('invert').velocity('transition.slideDownBigIn');}
            //Loads gif on slide entrance
            if (nextIndex === 3) { $rootScope.gif1Src = angular.element(document.querySelector('#gif_1_src')).attr('data-tempsrc'); }
            if (nextIndex === 4) { $rootScope.gif2Src = angular.element(document.querySelector('#gif_2_src')).attr('data-tempsrc'); }
            if (nextIndex === 5) { $rootScope.gif3Src = angular.element(document.querySelector('#gif_3_src')).attr('data-tempsrc'); }
            if (nextIndex === 6) { $rootScope.gif4Src = angular.element(document.querySelector('#gif_4_src')).attr('data-tempsrc'); }
            $rootScope.$apply();
            $('.gif'+index).removeClass('hidden');
          }, 650);
        },
        afterLoad: function() {
          // Removes tooltips (conflicts with foundation tooltips)
          $('#pp-nav li').removeAttr('data-tooltip');
          // Removes page anchors
          $('#pp-nav a').removeAttr('href');
          $(document).off('mouseenter', '#pp-nav li');

          animateActiveNav();
          $('#pp-nav').fadeIn('slow');
          $('#dim_the_lights').css('opacity','1');

        },
        afterRender: function() {
          $('#pp-nav').hide();
        }
      });

      if ($location.path() === '/create-wealth') {
        $.fn.pagepiling.setAllowScrolling(false);
      } else {
        $.fn.pagepiling.setAllowScrolling(true);
      }

      function animateActiveNav(){
        if($('.pp-section.active').hasClass('inverted')){
          $('#pp-nav').find('span').animate({backgroundColor:'transparent'},200);
          $('a.active').find('span').animate({backgroundColor:'#fff'},100);
        } else {
          $('#pp-nav').find('span').animate({backgroundColor:'transparent'},200);
          $('a.active').find('span').animate({backgroundColor:'#555'},100);
        }
      }

      function changeNavColor() {
        if($('.pp-section.active').hasClass('inverted')){
          $('#pp-nav').find('span').animate({borderColor:'#fff'},200);
          $('a.active').find('span').css('background','#fff');
        } else {
          $('#pp-nav').find('span').animate({borderColor:'#555'},200);
          $('a.active').find('span').css('background','#555');
        }
      }
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

    $rootScope.setupInvertHeader = function() {
      angular.element($window).bind('scroll', function() {
        var header = document.getElementById('sun_header_guest');
        if (header && header.className !== 'sun-header-guest invert') {
          header.setAttribute('class', 'sun-header-guest hidden');
          setTimeout(function invertHeader() {
            header.setAttribute('class', 'sun-header-guest invert');
          }, 200);
        }
      });
    };

    $rootScope.enableScrollDetect = function() {
      $(window).scroll(function () {
        var screenHeight = $(window).height() - ($(window).height() / 1.4);
        var scrollPos = $(window).scrollTop();
        if($('.sun-header-guest').hasClass('velocity-animating')) return;
        if(scrollPos < screenHeight && $('.sun-header-guest').hasClass('invert')) {
          $('.sun-header-guest').velocity('transition.slideUpBigOut', function() {
            $('.sun-header-guest').toggleClass('invert').show().velocity({ opacity: 1 }, 200);
          });
        }
        if(scrollPos > screenHeight && !$('.sun-header-guest').hasClass('invert')) {
          $('.sun-header-guest').toggleClass('invert').velocity('transition.slideDownBigIn');
        }
      });
    };

    $rootScope.isMenuLinkActive = function(path) {
      if (path === $location.path()) return true;
      return false;
    };

    $rootScope.signOut = function() {
      var cb = function() {
        $rootScope.isSignedIn = false;
        // window.location = '#/sign-in';
        $location.path('/sign-in');
      };
      $http.delete('/login.json', {
        xsrfHeaderName: 'X-CSRF-Token'
      }).success(cb).error(cb);
    };

    $rootScope.gotoAnchor = function(id) {
      if(id === 'dim_the_lights') $('body').css('background','#111');
      var duration = 500;
      var offset = 0; // pixels; adjust for floating menu, context etc
      // Scroll to #some-id with N px 'padding'
      $('.sun-bg-1').animate({ opacity: '0' }, 700, function() {
        var someElement = angular.element(document.getElementById(id));
        $document.scrollToElement(someElement, offset, duration);
        setTimeout(function(){
          $('body').css('background','transparent');
          //prevents users from getting stuck on second slide
          if (id === 'dim_the_lights') {
            $('.sun-bg-1').hide();
            $('body').scrollTop(0);
          }
          if (id === 'on_slider_move') {
            // $('body').css('background','transparent')
            $('.sun-bg-1').css('opacity','1').show();
            $(window).scrollTop($('.sun-promo-slide-3').offset().top);
            if($('body').css('overflow') !== 'visible') {
              $('body').css('overflow','visible');
              $('.sun-header-guest').toggleClass('invert').velocity('transition.slideDownBigIn');
              $rootScope.enableScrollDetect();
            }
          }
        }, 700);
      });
    };
  }
]);

var sunstandControllers = angular.module(
  'sunstandControllers',
  []
);

var sunstandServices = angular.module(
  'sunstandServices',
  ['ngResource', 'uiSlider', 'duScroll']
);
