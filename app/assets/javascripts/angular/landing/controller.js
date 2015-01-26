'use strict';

function LandingCtrl($scope, $rootScope, $http, $location, $routeParams, $timeout, $interval, Invite, Geo) {
  $scope.redirectToDashboardIfSignedIn();
  $scope.showValidationMessages = false;
  $scope.isSubmitDisabled = false;

  // $scope.animatedGif = '<%=asset_path()%>'

  $scope.isMenuActive = false;
  $scope.hideMenuClick = function() {
    $scope.isMenuActive = false;
  };
  $scope.showMenuClick = function() {
    $scope.isMenuActive = true;
  };

  $scope.signIn = function() {
    if ($scope.user && $scope.user.email && $scope.user.password) {
      $http.post('/login.json', {
        email: $scope.user.email,
        password: $scope.user.password,
        remember_me: $scope.user.remember_me
      }, {
        xsrfHeaderName: 'X-CSRF-Token'
      }).
      success(function(data) {
        if (data.error) {
          $('<div class=\'reveal-modal\' data-reveal><h3>Oops, wrong email or password</h3><a class=\'close-reveal-modal\'>&#215;</a></div>').foundation('reveal', 'open');
          $(document).foundation();
        } else {
          $rootScope.isSignedIn = true;
          $scope.redirectToDashboardIfSignedIn();
        }
      }).
      error(function() {
        console.log('Sign In Error');
      });
    } else {
      $scope.showValidationMessages = true;
    }
  };

  $scope.validateInvite = function() {
    var code;
    if ($scope.invite && $scope.invite.code) {
      Invite.validate($scope.invite.code).then(function(data) {
        if (data.error) {
          $scope.invite = {};
          $scope.user = {};
          $scope.invite.error = data.error;
        } else {
          code = $scope.invite.code;
          $scope.invite = data;
          $scope.invite.code = code;
          $scope.user.first_name = data.properties.first_name;
          $scope.user.last_name = data.properties.last_name;
          $scope.user.email = data.properties.email;
        }
      });
    }
  };

  var signUpCallback = function(data) {
    $scope.formErrorMessages = {};
    if (data.errors) {
      $.each(data.errors, function(key, errors) {
        // Only take first error message from the array
        var errorMessage = errors[0];
        if (errorMessage) {
          $scope.formErrorMessages[key] = errors[0];
        }
      });
    } else {
      $location.path('/sign-in');
      $('<div class=\'reveal-modal\' data-reveal><h3>You\'ve successfully Signed Up. Now you may Sign In.</h3><a class=\'close-reveal-modal\'>&#215;</a></div>').foundation('reveal', 'open');
      $(document).foundation();
    }
    $scope.isSubmitDisabled = false;
  };
  $scope.signUp = function() {
    if ($scope.user) {
      $scope.isSubmitDisabled = true;
      var path;
      for (var i in $scope.invite.actions) {
        if ($scope.invite.actions[i].name === 'create_account') {
          path = $scope.invite.actions[i].href;
        }
      }
      Invite.signUp($scope.invite.properties.id, $scope.user, path).then(signUpCallback);
    }
  };

  $scope.clearInviteValidationForm = function() {
    $scope.invite = {};
    $scope.user = {};
  };

  $scope.resetPassword = function() {
    if ($scope.user && $scope.user.email) {
      $http.post('/password.json', {
        email: $scope.user.email
      }, {
        xsrfHeaderName: 'X-CSRF-Token'
      }).
      success(function() {
        $location.path('/sign-in');
        $('<div class=\'reveal-modal\' data-reveal><h3>We received your request. You\'ll get an email if we have an account associated with it.</h3><a class=\'close-reveal-modal\'>&#215;</a></div>').foundation('reveal', 'open');
        $(document).foundation();
      }).
      error(function() {
        console.log('Reset Password Error');
      });
    } else {
      $scope.showValidationMessages = true;
    }
  };

  $scope.updatePassword = function() {
    if ($scope.user && $scope.user.password && $scope.user.password_confirm) {
      $http.put('/password.json', {
        password: $scope.user.password,
        password_confirm: $scope.user.password_confirm,
        token: $routeParams.resetPasswordToken
      }, {
        xsrfHeaderName: 'X-CSRF-Token'
      }).
      success(function(data) {
        if (data.error) {
          $('<div class=\'reveal-modal\' data-reveal><h3>' + data.error.message + '</h3><a class=\'close-reveal-modal\'>&#215;</a></div>').foundation('reveal', 'open');
          $(document).foundation();
        } else {
          $location.path('/sign-in');
          $('<div class=\'reveal-modal\' data-reveal><h3>' + data.properties._message.confirm + '</h3><a class=\'close-reveal-modal\'>&#215;</a></div>').foundation('reveal', 'open');
          $(document).foundation();
        }
      }).
      error(function() {
        console.log('Reset Password Error');
      });
    } else {
      $scope.showValidationMessages = true;
    }
  };

  this.init($scope, $location, $timeout);
  this.fetch($scope, $interval, $routeParams, Geo);
}


LandingCtrl.prototype.init = function($scope, $location, $timeout) {
  $timeout(function() {
    $scope.invertHeaderColor();
  }, 2000);

  // Setting mode based on the url
  $scope.mode = '';
  if (/\/home$/.test($location.path())) return $scope.mode = 'home';
  if (/\/sign-in$/.test($location.path())) return $scope.mode = 'sign-in';
  if (/\/customer-faq$/.test($location.path())) return $scope.mode = 'customer-faq';
  if (/\/advocate-faq$/.test($location.path())) return $scope.mode = 'advocate-faq';
  if (/\/sign-up/.test($location.path())) return $scope.mode = 'sign-up';
};


LandingCtrl.prototype.fetch = function($scope, $interval, $routeParams, Geo) {
  if ($scope.mode === 'home') {
    // Only for home page
    $scope.currentHomeSlide = 0;
    var sliderStop = $interval(function() {
      $scope.currentHomeSlide += 1;
      if ($scope.currentHomeSlide >= 3) {
        $interval.cancel(sliderStop);
        sliderStop = undefined;
      }
    }, 2000);
  } else if ($scope.mode === 'sign-in') {
    // Only for sign in page
    $scope.signInPage = true;
  } else if ($scope.mode === 'customer-faq' || $scope.mode === 'advocate-faq') {
    // Only for faq pages
    $scope.activeFAQItemId = 'faq_item_1';
    $scope.faqHeaderTitle = $scope.mode === 'customer-faq' ?
      'Powur Customer FAQ' :
      'Powur Advocate FAQ';
  } else if ($scope.mode === 'sign-up') {
    // Only for sign up page
    $scope.invite = {};
    $scope.user = {};
    $scope.countries = Geo.countries();
    $scope.states = Geo.states();
    $scope.invite.code = $routeParams.inviteCode;
    if ($scope.invite.code) $scope.validateInvite();
  }
};
  
  var slide = 0
  function slideTransition(direction){
    if(direction == "down"){
      slide+=1
      // if(slide === 1) $('.gif1').css('background',"url('landing/globe.gif')");
      $('#slide-dot'+(slide+1)).addClass('active').siblings().removeClass('active')
      $('.sun-bg-'+slide).slideUp(1500,'easeOutExpo', function(){
         $(window).bind('DOMMouseScroll mouswheel', mouseWheel());
         $(window).bind('click', arrowNav());
      });
    } else {
      $('#slide-dot'+(slide)).addClass('active').siblings().removeClass('active')
      $('.sun-bg-'+slide).slideDown(1500,'easeOutExpo', function(){
          slide-=1
         $(window).bind('DOMMouseScroll mouswheel', mouseWheel());
         $(window).bind('click', arrowNav());
      });
  
    }

   

    var header = document.getElementById('sun_header_guest');

    if (!header) return;

    if (slide > 0) {
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


  function arrowNav(){
    $(document).on('click', '.sun-next-pointer',function(e){
      e.preventDefault();
      $(document).unbind()
      slideTransition('down')
    });
  }

  function mouseWheel(){

  $(document).bind('DOMMouseScroll mousewheel', function(e){
    // $(window).unbind('DOMMouseScroll mouswheel', mouseWheel());
     if( e.originalEvent.detail > 0 || e.originalEvent.wheelDelta < 0 ) {
      if(slide !== 6){
        $(document).unbind()
        slideTransition('down')
      }
     } else {
        if(slide !== 0){
          $(document).unbind()
          slideTransition('up')
        }
      }
      //prevent page fom scrolling
      return false;
    });
  }

  $(document).on('click','.slide-dot', function(e){
    if($(this).hasClass('active')) return;
    var value = parseInt($(this).attr('data')) 
    slideDotTransition(value);
  })


  function slideDotTransition(value){
      var speed1 = 0
      var speed2 = 0
      if(slide > value) speed1 = 1500
      else speed2 = 1500
      slide = value 
      $('#slide-dot'+slide).addClass('active').siblings().removeClass('active')
      for(var i=0; i < 7; i++){
        if(i === slide) $('.sun-bg-'+i).slideDown(speed1,'easeOutExpo', function(){});
        else $('.sun-bg-'+i).slideUp(speed2,'easeOutExpo', function(){});
      }
   
  }

  setTimeout(function() { 
    arrowNav()
    mouseWheel(); 
  },6500);





LandingCtrl.$inject = ['$scope', '$rootScope', '$http', '$location', '$routeParams', '$timeout', '$interval', 'Invite', 'Geo'];
sunstandControllers.controller('LandingCtrl', LandingCtrl);
