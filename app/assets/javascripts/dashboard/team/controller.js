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
        rewindNav: false,
        scrollPerPage: true,
        mouseDrag: false,
        touchDrag: true,
        beforeMove: false
      });
    };

    // Destroy Carousel
    var destroyCarousel = function(carouselElement) {
      $(carouselElement).data('owlCarousel').destroy();
    };

    // Show Team Member
    $scope.teamSection.showTeamMember = function(userId) {
      if ($scope.showingTeamMember === true && $scope.currentTeamMember.id === userId) {
        $scope.showingTeamMember = false;
        $scope.currentTeamMember = {};
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
