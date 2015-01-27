'use strict';

function SunScrollCtrl($scope, $rootScope, $location, $routeParams, $timeout, $interval) {
  $scope.currentSlide = 0;
  $scope.selectedSlide = 0;
  $scope.dots = []
  // $scope.dots = [{active:true},{active:false},{active:false},{active:false},{active:false},{active:false},{active:false}];


  $scope.scrollTimeout = function() {
    $timeout(function() {
      $scope.mouseWheel();
    }, 6500);
  }

  $scope.clickArrowNav = function() {
    $(document).unbind();
    $scope.slideTransition('down');
  }

  $scope.clickSlideDot = function(value){
    // if($(this).hasClass('active')) return;
    $scope.selectedSlide = value 
    $scope.slideNavigation();
  }

  $scope.createDots = function(n) {
    for(var i=0;i<n;i++){
      if(i === 0){
        $scope.dots.push({active:true})
      } else {
        $scope.dots.push({active:false})
      }
    }
  }

  $scope.mouseWheel = function() {
    $(document).bind('DOMMouseScroll mousewheel', function(e){
      if( e.originalEvent.detail > 0 || e.originalEvent.wheelDelta < 0 ) {
        if($scope.currentSlide !== $('.sun-scrolling-bg').length - 1){
          $(document).unbind()
          $scope.slideTransition('down')
        }
      } else {
        if($scope.currentSlide !== 0){
          $(document).unbind()
          $scope.slideTransition('up')
        }
      }
      //prevent page fom scrolling
      return false;
    });
  }

  $scope.slideTransition = function(direction) {
    if(direction == "down"){
      $scope.dots[$scope.currentSlide].active = false;
      $scope.currentSlide += 1;
      $scope.dots[$scope.currentSlide].active = true;
      $scope.$apply();
      $('.scroll-slide-'+$scope.currentSlide).slideUp(1500,'easeOutExpo', function(){
        $(window).bind('DOMMouseScroll mouswheel', $scope.mouseWheel());
      });
    } else {
      $scope.dots[$scope.currentSlide].active = false;
      $('.scroll-slide-'+$scope.currentSlide).slideDown(1500,'easeOutExpo', function(){
        $scope.currentSlide-=1
        $scope.dots[$scope.currentSlide].active = true;
        $scope.$apply();
        $(window).bind('DOMMouseScroll mouswheel', $scope.mouseWheel());
      });
  
    }

    var header = document.getElementById('sun_header_guest');

    if (!header) return;

    if ($scope.currentSlide > 0) {
      if (header.className !== 'sun-header-guest invert') {
        header.setAttribute('class', 'sun-header-guest hidden');
        setTimeout(function invertHeader() {
          header.setAttribute('class', 'sun-header-guest invert');
        }, 200);
      }
    } else {
      if (header.className !== '') {
        header.setAttribute('class', 'sun-header-guest hidden');
        setTimeout(function invertHeader() {
          header.setAttribute('class', 'sun-header-guest');
        }, 200);
      }
    }
  }

  $scope.slideNavigation = function() {
    var speed1 = 0
    var speed2 = 0
    if($scope.currentSlide > $scope.selectedSlide){
      speed1 = 1500;
    } else { 
      speed2 = 1500;
    }

    $scope.dots[$scope.currentSlide].active = false;
    $scope.currentSlide = $scope.selectedSlide;
    debugger
    $scope.dots[$scope.currentSlide].active = true;

    for(var i=0; i < 7; i++){
      if(i === $scope.currentSlide) $('.scroll-slide-'+(i+1)).slideDown(speed1,'easeOutExpo', function(){});
      else $('.scroll-slide-'+(i+1)).slideUp(speed2,'easeOutExpo', function(){});
    }
  }


  $scope.createDots(7)
  $scope.scrollTimeout();
}

SunScrollCtrl.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$timeout', '$interval'];
sunstandControllers.controller('SunScrollCtrl', SunScrollCtrl);
