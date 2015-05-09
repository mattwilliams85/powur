;(function() {
  'use strict';

  function DashboardTeamCtrl($scope, $timeout, User, Invite) {
    $scope.redirectUnlessSignedIn();
    $scope.showInvitesCarousel = false;

    $scope.legacyImagePaths = legacyImagePaths;
    $scope.downline = [];
    $scope.currentTeamMember = {};

    // Initialize Carousel
    var initCarousel = function(carouselElement) {
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
        beforeMove: closeForm
      });
    };

    // Close Team Member Show when Moving Carousel
    var closeForm = function(event) {
      if ($scope.updatingProposal !== true) {
        $timeout(function() {
          $scope.closeForm();
        });
      }
    };
    // Close Team Member
    $scope.closeForm = function() {
      $scope.showingTeamMember = false;
      $scope.currentTeamMember = {};
    };

    // Destroy Carousel
    var destroyCarousel = function(carouselElement) {
      $(carouselElement).data('owlCarousel').destroy();
    };

    $scope.memberActive = function(teamMember) {
      return $scope.currentTeamMember.id === teamMember.properties.id;
    };

    // Show Team Member
    $scope.changeTab = function(teamMember, tab) {
      console.log(tab)
      if ($scope.showingTeamMember && $scope.currentTeamMember.id === teamMember.properties.id) {
        $scope.closeForm();
        return;
      } else {
        $scope.activeTab = tab;
        if (tab === 'info') {
          User.get(teamMember.properties.id).then(function(item){
            $scope.currentTeamMember = item.properties;
            $scope.showingTeamMember = true;
          });
        } else if (tab === 'team') {
          // debugger
          $scope.downline = $scope.downline.slice(0, teamMember.properties.level - 1);
          console.log($scope.downline)
          User.downline(teamMember.properties.id).then(function(item){
          
            $scope.downline.push(item.entities);
          });
        } else {
          console.log('you clicked KPI');
        }
      }
    };

    // Show New Invite Form
    $scope.teamSection.newInvite = function() {

    };

    // Show Invites
    $scope.teamSection.showInvites = function() {
      if ($scope.showInvitesCarousel === true) {
        $scope.closeCarousel();
        return;
      } else {
        $scope.showInvitesCarousel = true;
        // $scope.animateDrilldown();

        Invite.list().then(function(items){
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

    // //Animations
    // $scope.animateTabsUp = function() {
    //   $(this).find('.tam_tab')
    //     .velocity({translateY: '-35px'},{queue: false}, 200);
    // };

    // $scope.animateTabsDown = function() {
    //   $(this).find('.team_tab').not('.active_tab')
    //     .velocity({translateY: '0px'},{queue: false}, 200);
    // };

    // $scope.animateDrilldown = function () {
    //   $scope.drilldownActive = false;
    //   $scope.drilldownActive = true;
    //   $timeout( function(){
    //     $scope.showInvitesCarousel = true;
    //   }, 300);
    // };

    $scope.onEnd = function(){
      initCarousel($('#carousel-' + ($scope.downline.length - 1)));
    };

    // Close Form
    $scope.closeCarousel = function() {
      // $scope.drilldownActive = false;
      $scope.showInvitesCarousel = false;
      destroyCarousel('.invites');
    };

    // Search Action
    $scope.teamSection.teamSearch = '';
    $scope.teamSection.search = function() {
      destroyCarousel('.team');
      var searchQuery = {search: $scope.teamSection.teamSearch};
      User.list(searchQuery).then(function(items) {
        $scope.teamMembers = items.entities;
        $timeout(function() {
          initCarousel('.team');
        });
      });
    };

    // Sort Action
    $scope.teamSection.teamSort = 'name';
    $scope.teamSection.sort = function() {
      destroyCarousel('.team');
      var sortQuery = {sort: $scope.teamSection.teamSort};
      User.list(sortQuery).then(function(items) {
        $scope.teamMembers = items.entities;
        $timeout(function() {
          initCarousel('.team');
        });
      });
    };

    return User.list().then(function(items) {
      $scope.downline.push(items.entities);
      $timeout(function() {
        initCarousel('.team');
      });
    });
  }

  DashboardTeamCtrl.$inject = ['$scope', '$timeout', 'User', 'Invite'];
  angular.module('powurApp').controller('DashboardTeamCtrl', DashboardTeamCtrl)
  angular.module('powurApp').directive("repeatEnd", function(){
  return {
    restrict: "A",
      link: function (scope, element, attrs) {
        if (scope.$last) {
          scope.$eval(attrs.repeatEnd);
        }
      }
    };
  });

})();
