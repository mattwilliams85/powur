;(function() {
  'use strict';

  function PromoCtrl($scope, $rootScope, $location, $timeout, $interval, $window, $anchorScroll, $routeParams) {
    $scope.redirectIfSignedIn();
    $scope.removePiler();
    $scope.inviteCode = null;

    $scope.isMenuActive = false;
    $scope.hideMenuClick = function() {
      $scope.isMenuActive = false;
    };
    $scope.showMenuClick = function() {
      $scope.isMenuActive = true;
    };

    $scope.setupPromoSlider = function(slides) {
      $scope.slides = slides;
      $scope.currentSlide = 0;
      $scope.sliderStop = $interval(function() {
        if ($scope.currentSlide >= $scope.slides.length - 1) {
          $scope.currentSlide = 0;
        } else {
          $scope.currentSlide += 1;
        }
      }, 20000);
    };

    $rootScope.animateArrow(1,3000)

    $scope.stopSlideShowOn = function(slide) {
      if (slide === parseInt(slide, 10)) { // check if integer
        $scope.currentSlide = slide;
      } else {
        $scope.currentSlide = $scope.slides.indexOf(slide);
      }
      $interval.cancel($scope.sliderStop);
      $scope.sliderStop = undefined;
    };

    $scope.navigateSlideShow = function(slide, direction) {
      // var i = $scope.slides.indexOf(slide);
      var length = 5;
      if(typeof $scope.slides !== "undefined") length = $scope.slides.length
      if(direction === 'left') {
        if(slide === 0) return;
        $scope.stopSlideShowOn(slide - 1);
      } else {
        if(slide === length - 1) return;
        $scope.stopSlideShowOn(slide + 1);
      }
    }

    $scope.energyPromoSlides = [
      {
        images: [
          legacyImagePaths.energyPromo[0],
          legacyImagePaths.energyPromo[1],
          legacyImagePaths.energyPromo[2]
        ],
        text: 'Lock in a lower rate on your electricity for the next 20 years, guaranteeing no more price increases or energy inflation!'
      },
      {
        images: [
          legacyImagePaths.energyPromo[3],
          legacyImagePaths.energyPromo[4],
          legacyImagePaths.energyPromo[5]
        ],
        text: 'SolarCity handles EVERYTHING from financing, to installation, to maintenance, to insurance and warranties... you have no worries.'
      },
      {
        images: [
          legacyImagePaths.energyPromo[6],
          legacyImagePaths.energyPromo[7],
          legacyImagePaths.energyPromo[8]
        ],
        text: 'Get peace of mind that your energy bills are protected, and you save money from this point forward.'
      }
    ];

    $scope.directSalePromoSlides = [
      {
        images: [
          'http://lorempixel.com/200/200/nature/1/',
          'http://lorempixel.com/200/200/nature/2/',
          'http://lorempixel.com/200/200/nature/9/'
        ],
        text: 'There is no industry as good at spreading products via word of mouth as ours.  Despite the often misunderstood nature of direct sales, the numbers don’t lie.  Direct sales has the potential to create millions of solar customers over the next decade… and generate BILLIONS in wealth for those who do.'
      },
      {
        images: [
          'http://lorempixel.com/200/200/nature/3/',
          'http://lorempixel.com/200/200/nature/4/',
          'http://lorempixel.com/200/200/nature/5/'
        ],
        text: 'We believe powur could be the start of a MEGA trend. A tipping point that sends solar on the “inflection” point everyone has theorized for years. With the cost of traditional electricity constantly increasing, and the cost of solar REDUCING every year... it’s just a matter of time before qualified homeowners make the switch to the cheaper, cleaner energy source. They call it “grid parity”... and it’s happening now.'
      },
      {
        images: [
          'http://lorempixel.com/200/200/nature/6/',
          'http://lorempixel.com/200/200/nature/7/',
          'http://lorempixel.com/200/200/nature/8/'
        ],
        text: 'Referral marketing is the #1 source of new solar customers, and with Powur, we take the power of referral marketing to new heights. If you’ve ever wanted to own your own business, have an unlimited income potential, and do something that leaves a lasting impact on our world for Centuries to come... you could not be in a better place at a better time.'
      }
    ];

    $scope.whySolarPromoSlides = [
      [
        {
          className: 'ico-1',
          text: 'The Department of Energy estimates that 2/3 of every home in America will get its power cheaper from solar than any other energy source by 2015.'
        },
        {
          className: 'ico-2',
          text: 'And many billions of dollars of institutional capital from the smartest money on the planet (Sequoia Capital, Goldman Sachs, Google, Bank of America, and so many more) is being invested in solar.'
        },
        {
          className: 'ico-3',
          text: 'Over 23,000 new jobs were added to the solar industry in 2013, 10x the national job average, bringing the total workers in solar to more than 145,000.  That’s as much as the entire 150-year-old coal industry. (and the market is less than 1% installed!)'
        }
      ],
      [
        {
          className: 'ico-4',
          text: 'Barclays has downgraded the utility energy sector referencing “Significant risk due to residential solar’s disruptive potential”'
        },
        {
          className: 'ico-5',
          text: 'Every three minutes a new American homeowner installs solar panels on their roof.'
        },
        {
          className: 'ico-6',
          text: 'More solar has been installed in the last 18 months than the previous 30 years.'
        }
      ]
    ];

    $scope.whySolarPromoSlidesSmall = $scope.whySolarPromoSlides
    $scope.whySolarPromoSlidesSmall = [].concat.apply([],$scope.whySolarPromoSlidesSmall);

    this.init($scope, $rootScope, $location, $timeout, $interval, $anchorScroll);
    this.fetch($scope, $rootScope, $interval, $timeout, $anchorScroll, $location, $routeParams);
  }


  PromoCtrl.prototype.init = function($scope, $rootScope, $location, $timeout, $interval, $anchorScroll) {
    $scope.$watch('slider', function(newValue) {
      if (newValue === '50') {
        $('.image-2').animate({opacity:'1'},200);
        $('.image-1').animate({opacity:'0.3'},200);
        $timeout(function() {
          if ($location.path() === '/create-energy') {
            $.fn.pagepiling.moveSectionDown();
          }
          $scope.gotoAnchor('on_slider_move');
        }, 400);
        $timeout(function() {
          $('.image-2').css("opacity",'0.3');
          $('.image-1').css("opacity",'1');
         $('.pointer').css('left',0);
        },2000)
      }
    });

    // Setting mode based on the url
    $scope.mode = '';
    if (/\/create-wealth/.test($location.path())) return $scope.mode = 'create-wealth';
    if (/\/create-energy$/.test($location.path())) return $scope.mode = 'create-energy';
    if (/\/why-solar$/.test($location.path())) return $scope.mode = 'why-solar';
    if (/\/why-you$/.test($location.path())) return $scope.mode = 'why-you';
    if (/\/why-powur$/.test($location.path())) return $scope.mode = 'why-powur';
    if (/\/why-direct-selling$/.test($location.path())) return $scope.mode = 'why-direct-selling';
    if (/\/our-origin$/.test($location.path())) return $scope.mode = 'our-origin';
    if (/\/our-team$/.test($location.path())) return $scope.mode = 'our-team';
    if (/\/our-dna$/.test($location.path())) return $scope.mode = 'our-dna';
  };


  PromoCtrl.prototype.fetch = function($scope, $rootScope,  $interval, $timeout, $anchorScroll, $location, $routeParams) {
    if ($scope.mode === 'create-wealth') {
      $(window).on('beforeunload', function() {
          $(window).scrollTop(0);
      });
      $('body').addClass('no-scroll')
      // $scope.setupInvertHeader();
      // Clock
      $scope.minTime = new Date(2000, 1, 1, 0, 0, 0, 0).valueOf();
      // Max time is 3 minutes
      $scope.maxTime = new Date(2000, 1, 1, 0, 0, 0, 0).valueOf() + (1000 * 60 * 3);
      $scope.solarTime = $scope.maxTime;
      $scope.solarTimerSeconds = '00';
      $scope.solarTimerMinutes = '03';
      $scope.solarTimerHours = '00';
      $scope.solarTimerPeople = 0;
      var timeStrings;
      $scope.solarTimerStop = $interval(function() {
        $scope.solarTime -= 1000;
        timeStrings = new Date($scope.solarTime).toTimeString().split(':');
        $scope.solarTimerHours = timeStrings[0];
        $scope.solarTimerMinutes = timeStrings[1];
        $scope.solarTimerSeconds = /^[\d]{2}/.exec(timeStrings[2])[0];
        if ($scope.solarTime === $scope.minTime) {
          $scope.solarTimerPeople += 1;
          $scope.solarTime = $scope.maxTime;
        }
      }, 1000);
      $scope.inviteCode = $routeParams.inviteCode;
    } else if ($scope.mode === 'create-energy') {
      $scope.readyPiler();
      $scope.setupPromoSlider($scope.energyPromoSlides);
      $scope.currentSlide = 0;
    } else if ($scope.mode === 'why-solar') {
      $scope.readyPiler();
      if(window.innerWidth <= 768) {
        $scope.setupPromoSlider($scope.whySolarPromoSlidesSmall);
      } else {
        $scope.setupPromoSlider($scope.whySolarPromoSlides);
      }
    } else if ($scope.mode === 'why-powur') {
      $scope.readyPiler();
    } else if ($scope.mode === 'why-you') {
      $scope.readyPiler();

      $scope.$watch("nextIndex", function() {
         if ($scope.nextIndex > 1) {
           $scope.currentSlide = -1;
           $timeout(function() {
             $scope.currentSlide += 1;
             $scope.sliderStop = $interval(function() {
               if ($scope.currentSlide >= 4) {
                 $scope.currentSlide = 0;
               } else {
                 $scope.currentSlide += 1;
               }
             }, 8000);
           }, 500);
         }
       });


    } else if ($scope.mode === 'why-direct-selling') {
      $scope.readyPiler();
      $scope.setupPromoSlider($scope.directSalePromoSlides);
    } else if ($scope.mode === 'our-origin') {
      $rootScope.enableScrollDetect();
    } else if ($scope.mode === 'our-dna') {
      $rootScope.enableScrollDetect();
    } else if ($scope.mode === 'our-team') {
      $rootScope.enableScrollDetect();
      $scope.faces = [
        {
          name: 'Jonathan Budd',
          title: 'Founder/CEO',
          image: legacyImagePaths.teamFaces[0],
          details: '  Jonathan heads up day-to-day operations and strategy that allow Powur’s entrepreneurs to succeed at their finest.  From forming key strategic partnerships, attracting the best talent, and innovating how solar is sold... Jonathan has his hands in everything Powur.  Prior to Powur, he built one of the largest online training and education companies in direct selling with more than 100,000 customers.  In 2010, he shifted his entrepreneurial pursuits toward projects focused on game-changing global impact.  He founded MyStand in 2011, which developed a first-of-its-kind gaming app to engage users in positive global change.  He is also Founder and Executive Director of The Global Transformation Council, Inc., a 501c3 organization that’s donated close to $1,000,000 to local and global initiatives for change.',
          showDetails: false
        },
        {
          name: 'Robert Styler',
          title: 'Co-Founder and President',
          image: legacyImagePaths.teamFaces[1],
          details: 'Robert has 25 years of success experience in direct sales, solar and senior management.  He is uniquely qualified to lead Powur’s sales Division as the company sets course to bring solar energy to the masses.  He earned “top 10” status in a number of direct selling companies over the years, including INC, Magazine’s 1996 “fastest growing company in the U.S.”  He also served as president of the marketing division for Incomnet Communications where he engineered a two-year turnaround strategy that resulted in the company’s shift from losing 30,000 customers a month to gaining 5,000 a month. From 2006-2010, Robert was president of the marketing division of Citizenre where he built a sales division comprising many talented leaders and broke records in the renewable energy space, signing more than 38,000 customer contracts.',
          showDetails: false
        },
        {
          name: 'Tyler Jensen',
          title: 'Interim CFO',
          image: legacyImagePaths.teamFaces[2],
          details: '  Tyler has 20+ years of experience in successful entrepreneurship and expanding business ventures, having launched and helped launch more than 100 companies and helping to raise more than $200 million for startup companies.  He plays a key role in a broad range of Powur’s operational and strategic areas, including business development, financial and growth strategies, budget forecasting, funding activities, among others.  He is the founder of The Startup Garage, a consulting firm specializing in helping entrepreneurs and business owners achieve success.  He also founded VAVi, a sport and social club which he grew to more than 25,000 members in six years and in 2008, sold for over 150 times the capital investment. ',
          showDetails: false
        },
        {
          name: 'Craig Jorgensen',
          title: 'Chief Designer',
          image: legacyImagePaths.teamFaces[3],
          details: '  Craig has led UI/UX on multiple direct selling company launches, including one of the fastest growing direct sales start-ups in history, reaching 1,000,000+ users in 78 days during its 2013 pre-launch. He has a foundation in traditional print and advertising coupled with digital applications know-how, which makes him an unstoppable force in Powur.',
          showDetails: false
        },
        {
          name: 'Rick Hou',
          title: 'Chief Technology Officer',
          image: legacyImagePaths.teamFaces[4],
          details: '  Rick oversees all development of Powur’s proprietary software platform, and leads the execution of the Company’s technology vision and strategy.  He is the founder of EyeCue Lab, a professional services incubator focused on providing technical and business expertise to startups, and has been the key architect in a wide array of technology projects including enterprise level applications, social networks, games, and SaaS e-commerce platforms. Rick thrives on rapid prototyping and bringing a concept to MVP and has put his love for all aspects of product development to good use for such companies as ESPN, Toyota, Disney Roambi, and Shazam.',
          showDetails: false
        },
        {
          name: 'Andrea Budd',
          title: 'Chief Operating Officer',
          image: legacyImagePaths.teamFaces[5],
          details: '  With nearly three decades of leadership experience at industrial, non-profit, financial services and training firms in both traditional and new economy businesses, Andrea’s focus is on developing and executing operational best practices across Powur’s financial, human resources, customer service, legal, and regulatory compliance activities.  She left the corporate world in 2009 to join Empowered Entrepreneurs, an educational and training company founded by Jonathan Budd, and shepherded its operational and financial stability during its period of rapid-fire growth. Previously, she was President of the philanthropic foundation for a 125-year old financial services firm.  Prior to that, she played a key communications role in the company’s demutualization and $854 million Initial Public Offering.',
          showDetails: false
        }
      ];
    }
  };

  PromoCtrl.$inject = ['$scope', '$rootScope', '$location', '$timeout', '$interval', '$window', '$anchorScroll', '$routeParams'];
  angular.module('powurApp').controller('PromoCtrl', PromoCtrl);
})();
