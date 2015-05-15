;(function() {
  'use strict';

  function DashboardTeamCtrl($scope, $timeout, User, CommonService) {
    $scope.redirectUnlessSignedIn();
    $scope.showInvitesCarousel = false;

    $scope.legacyImagePaths = legacyImagePaths;
    $scope.downline = [];
    $scope.currentTeamMember = {};
    $scope.teamSection.teamSort = 'name';
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
            $scope.closeForm(null, element);
          });
        }
      };
    }

    // Close Team Member
    $scope.closeForm = function(teamMember, element) {
      if(teamMember) {
        $scope.downline = $scope.downline.slice(0, teamMember.properties.level - $scope.level);
      }
      if(element) {
        $scope.downline = $scope.downline.slice(0, parseInt(element.attr('data-row')) + 1);
      }
      $scope.activeTab = '';
      $scope.currentTeamMember = {};
    };

    function destroyCarousel(carouselElement) {
      $(carouselElement).data('owlCarousel').destroy();
    }

    // Show Team Member
    $scope.changeTab = function(teamMember, tab) {
      if ($scope.currentTeamMember.id === teamMember.properties.id && $scope.activeTab === tab || $scope.activeTab === 'team' && $scope.downline.length > teamMember.properties.level) {
        $scope.closeForm(teamMember);
      } else {
        $scope.activeTab = ''
        $scope.currentTeamMember = teamMember.properties;
        $scope.downline = $scope.downline.slice(0, teamMember.properties.level - $scope.level);

        if (tab === 'info') {
          $timeout(function(){
            $scope.showInfo = true;
            $scope.activeTab = tab;
            $scope.currentTeamMember = teamMember.properties;
          }, 100);
        } else if (tab === 'team') {
          User.downline(teamMember.properties.id, {sort: $scope.teamSection.teamSort}).then(function(item){
            $scope.activeTab = tab;
            $scope.downline.push(item.entities);
          });
        } else {
          $timeout(function(){
            $scope.activeTab = tab;
          }, 300);
        }
      }
    };

    $scope.levelGap = function(teamMember) {
      return teamMember.properties.level - $scope.level;
    }

    // Show Invites
    $scope.teamSection.showInvites = function() {
      if ($scope.showInvitesCarousel === true) {
        $scope.closeCarousel();
        return;
      } else {
        $scope.showInvitesCarousel = true;
        // $scope.animateDrilldown();

        CommonService.execute({
          href: '/u/invites.json'
        }).then(function(items){
          $scope.invites = items.entities;
          $scope.invitesAvailable = items.properties.remaining;

          for (var i = 0; i < $scope.invitesAvailable; i++) {
            $scope.invites.push({type: 'empty'});
          }

          $timeout(function() {
            initCarousel('.invites');
          });
        });
      }
    };

    // Close Form
    $scope.closeCarousel = function() {
      // $scope.drilldownActive = false;
      $scope.showInvitesCarousel = false;
      destroyCarousel('.invites');
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
          $scope.closeForm(null, $('#carousel-0'));
        });
      });
    };

    $scope.isMobile = function() {
      if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
       return true;
      }
    };

    // Sort Action
    $scope.teamSection.sort = function() {
      $scope.closeForm(null, $('#carousel-0'));
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

    return User.list({sort: $scope.teamSection.teamSort}).then(function(items) {
      $scope.downline.push(items.entities);
      $timeout(function() {
        initCarousel($('#carousel-0'));
        $scope.level = $scope.currentUser.level;
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
