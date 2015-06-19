;(function() {
  'use strict';

  function DashboardTeamCtrl($scope, $timeout, User, CommonService) {
    $scope.redirectUnlessSignedIn();
    $scope.showInvitesCarousel = false;

    $scope.legacyImagePaths = legacyImagePaths;
    $scope.downline = [];
    $scope.currentTeamMember = {};

    var level;

    // Initialize Carousel
    function initCarousel(carouselElement) {
      $(carouselElement).owlCarousel({
        items: 4,
        itemsCustom: false,
        itemsDesktop: [1199,4],
        itemsDesktopSmall : [1024,3],
        itemsTablet: [768,2],
        itemsTabletSmall: false,
        itemsMobile: [640,1],
        navigation: true,
        navigationText: false,
        rewindNav: true,
        rewindSpeed: 200,
        scrollPerPage: true,
        slideSpeed: 500,
        mouseDrag: false,
        touchDrag: true,
        lazyLoad: true,
        beforeMove: closeForm(carouselElement)
      });
    }

    // Close Team Member Show when Moving Carousel
    function closeForm(element) {
      return function() {
        if ($scope.updatingProposal !== true) {
          $timeout(function() {
            $scope.closeForm(element);
          });
        }
      };
    }

    // Device Detection
    $scope.isMobile = function() {
      if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
       return true;
      }
    };

    $scope.isActiveTab = function(teamMember, gen, tab) {
     if (tab) return gen.tab === tab && gen.selected === teamMember.properties.id && $scope.activeTab === tab;
     return ($scope.downline.length > ($scope.levelGap(teamMember))) && gen.selected === teamMember.properties.id;
    };

    $scope.isActiveMember = function(teamMember, gen) {
      return gen.selected === teamMember.properties.id;
    }

    // Close Team Member
    $scope.closeForm = function(element) {
      if(element) {
        $scope.downline = $scope.downline.slice(0, parseInt(element.attr('data-row')) + 1);
        $scope.downline[$scope.downline.length - 1].selected = "";
      }
      $scope.currentTeamMember = {};
      $scope.activeTab = '';
    };

    function destroyCarousel(carouselElement) {
      $(carouselElement).data('owlCarousel').destroy();
    }

    // Show Team Member
    $scope.changeTab = function(teamMember, gen, tab) {
      if ($scope.disable) return;
      // Set active tab for generation
      gen.selected = teamMember.id;
      gen.tab = tab;
      
      // Delay for transition between multiple animations
      var delay = 300;
      if (!$scope.activeTab) delay = 0;
      if($scope.currentTeamMember.id === teamMember.id && $scope.activeTab === tab) {

        // Remove active tab for generation
        gen.selected = null;
        gen.tab = null;

        $scope.closeForm();
        $scope.downline[$scope.downline.length - 1].selected = "";
      } else {
        $scope.closeForm();
        $scope.currentTeamMember = teamMember;

        // Set active tab for generation
        gen.selected = teamMember.id;
        gen.tab = tab;

        if (tab === 'team') {
          $scope.disable = true;
          User.downline(teamMember.id, {sort: $scope.teamSection.teamSort}).then(function(items) {
            $timeout(function(){
              $scope.activeTab = tab;
              for (var i = 0; i < items.entities.length; i++){
                items.entities[i].properties.defaultAvatarThumb = randomThumb();
              }
              $scope.downline.push(items.entities);
              $scope.disable = false;
            }, delay);
          });
        } else {
          $timeout(function(){
            $scope.activeTab = tab;
          }, delay);
        }
      }
      $scope.downline = $scope.downline.slice(0, $scope.levelGap(teamMember));
    };

    $scope.levelGap = function(teamMember) {
      if(teamMember.properties) return teamMember.properties.level - level;
      return teamMember.level - level;
    };

    //On ng-repeat load
    $scope.onEnd = function(){
      $timeout(function(){
        initCarousel($('#carousel-' + ($scope.downline.length - 1)));
      });
    };

    // Search Action
    $scope.teamSection.teamSearch = '';

    $scope.teamSection.search = function() {
      for (var i = 0; i < $scope.downline.length; i++){
        destroyCarousel('#carousel-'+ i);
      }
      var searchQuery = {search: $scope.teamSection.teamSearch};
      User.list(searchQuery).then(function(items) {
        $scope.downline = [items.entities];
        $timeout(function() {
          initCarousel($('#carousel-0'));
          $scope.closeForm($('#carousel-0'));
        });
      });
    };

    // Sort Action
    $scope.teamSection.teamSort = 'name';

    $scope.teamSection.sort = function() {
      $scope.closeForm($('#carousel-0'));
      var sortQuery = {sort: $scope.teamSection.teamSort};
      for (var i = 0; i < $scope.downline.length; i++){
        destroyCarousel('#carousel-'+ i);
      }

      User.list(sortQuery).then(function(items) {
        $scope.downline = [items.entities];
        $timeout(function() {
          initCarousel($('#carousel-0'));
        });
      });
    };

    function randomThumb() {
      return legacyImagePaths.defaultAvatarThumb[Math.floor(Math.random() * 3) ];
    }

    // Fetch User's Immediate downline
    return User.list({sort: $scope.teamSection.teamSort}).then(function(items) {
      for (var i = 0; i < items.entities.length; i++){
        items.entities[i].properties.defaultAvatarThumb = randomThumb();
      }

      $scope.downline.push(items.entities);
      $timeout(function() {
        initCarousel($('#carousel-0'));
        level = $scope.currentUser.level;
      });
    });
  }

  DashboardTeamCtrl.$inject = ['$scope', '$timeout', 'User', 'CommonService'];
  angular.module('powurApp').controller('DashboardTeamCtrl', DashboardTeamCtrl)
  .directive('repeatEnd', function(){
    return {
      restrict: 'A',
        link: function (scope, element, attrs) {
          if (scope.$last) {
            scope.$eval(attrs.repeatEnd);
          }
        }
      };
  });
})();
