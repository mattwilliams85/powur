;(function() {
  'use strict';

  function DashboardTeamCtrl($scope, $timeout, User, Invite) {
    $scope.redirectUnlessSignedIn();
    $scope.showInvitesCarousel = false;

    $scope.legacyImagePaths = legacyImagePaths;

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

    // Show Team Member
    $scope.teamSection.showTeamMember = function(userId) {
      if ($scope.showingTeamMember === true && $scope.currentTeamMember.id === userId) {
        $scope.closeForm();
        return;
      } else {
        User.get(userId).then(function(item){
          $scope.currentTeamMember = item.properties;
          $scope.showingTeamMember = true;
        });
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

    // $scope.animateDrilldown = function () {
    //   $scope.drilldownActive = false;
    //   $scope.drilldownActive = true;
    //   $timeout( function(){
    //     $scope.showInvitesCarousel = true;
    //   }, 300);
    // };

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

    return User.list().then(function(items) {
      $scope.teamMembers = items.entities;
      $timeout(function() {
        initCarousel('.team');
      });
    });
  }

  DashboardTeamCtrl.$inject = ['$scope', '$timeout', 'User', 'Invite'];
  angular.module('powurApp').controller('DashboardTeamCtrl', DashboardTeamCtrl);

})();
