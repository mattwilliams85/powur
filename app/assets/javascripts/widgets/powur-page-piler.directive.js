;(function() {
  'use strict';

  //
  // TODO: refactor this directive to get rid of $rootScope
  //

  function powurPagePiler($rootScope, $timeout) {
    function link(scope) {
      scope.internalControl = scope.control || {};

      /*
       * Bindable functions
       */
      scope.internalControl.removePiler = function() {
        $('html').removeClass('piling-on');
        $('body').removeClass('no-scroll');
        $('#pp-nav').remove();
      };

      scope.internalControl.readyPiler = function() {
        $('html').addClass('piling-on');
        scope.internalControl.pagePiler();
      };

      scope.internalControl.pagePiler = function() {
        if ($('#pagepiling').length === 0) return;

        $('.fa-chevron-down, .bulb-btn, .go-to-anchor').click(function(e) {
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
          onLeave: pilerOnLeave,
          afterLoad: pilerAfterLoad,
          afterRender: pilerAfterRender
        });

        if (scope.internalControl.setAllowScrolling === false) {
          $.fn.pagepiling.setAllowScrolling(false);
        } else {
          $.fn.pagepiling.setAllowScrolling(true);
        }
      };


      /*
       * Private functions
       */
      function animateActiveNav() {
        if ($('.pp-section.active').hasClass('inverted')) {
          $('#pp-nav').find('span').animate({backgroundColor:'transparent'}, 200);
          $('a.active').find('span').animate({backgroundColor:'#fff'}, 100);
        } else {
          $('#pp-nav').find('span').animate({backgroundColor:'transparent'}, 200);
          $('a.active').find('span').animate({backgroundColor:'#555'}, 100);
        }
      }

      function changeNavColor() {
        if ($('.pp-section.active').hasClass('inverted')) {
          $('#pp-nav').find('span').animate({borderColor:'#fff'},200);
          $('a.active').find('span').css('background','#fff');
        } else {
          $('#pp-nav').find('span').animate({borderColor:'#555'},200);
          $('a.active').find('span').css('background','#555');
        }
      }

      function getTempSrc(id) {
        angular.element(document.querySelector(id)).attr('data-tempsrc');
      }

      function pilerOnLeave(index, nextIndex) {
        changeNavColor();
        $rootScope.animateArrow(nextIndex, 1800);
        $rootScope.nextIndex = nextIndex;
        $timeout(function() {
          if (nextIndex === 1) {
            $('.pow-header-guest').velocity('transition.slideUpBigOut', function() {
              $('.pow-header-guest')
                .toggleClass('invert').show().velocity({ opacity: 1 }, 200);
            });
          }
          if (nextIndex > 1 && !$('.pow-header-guest').hasClass('invert')) { $('.pow-header-guest').toggleClass('invert').velocity('transition.slideDownBigIn');}
          // Loads gif on slide entrance
          if (nextIndex === 3) { $rootScope.gif1Src = getTempSrc('#gif_1_src'); }
          if (nextIndex === 4) { $rootScope.gif2Src = getTempSrc('#gif_2_src'); }
          if (nextIndex === 5) { $rootScope.gif3Src = getTempSrc('#gif_3_src'); }
          if (nextIndex === 6) { $rootScope.gif4Src = getTempSrc('#gif_4_src'); }
          scope.$apply();
          $('.gif'+index).removeClass('hidden');
        }, 650);
      }

      function pilerAfterLoad() {
        // Removes tooltips (conflicts with foundation tooltips)
        $('#pp-nav li').removeAttr('data-tooltip');
        // Removes page anchors
        $('#pp-nav a').removeAttr('href');
        $(document).off('mouseenter', '#pp-nav li');
        animateActiveNav();
        $('#pp-nav').fadeIn('slow');
        $('#dim_the_lights').css('opacity','1');
      }

      function pilerAfterRender() {
        $('#pp-nav').hide();
      }

      /*
       * Init
       */
      scope.$on('$locationChangeStart', function() {
        scope.internalControl.removePiler();
      });
      scope.internalControl.removePiler();
      scope.internalControl.readyPiler();
    }

    return {
      restrict: 'A',
      scope: {
        control: '='
      },
      link: link
    };
  }

  powurPagePiler.$inject = ['$rootScope', '$timeout'];

  angular
    .module('widgets.powurPagePiler', [])
    .directive('powurPagePiler', powurPagePiler);

})();
