;(function() {
  'use strict';

  function DashboardTeamCtrl($scope, $timeout, User) {
    $scope.redirectUnlessSignedIn();

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
        beforeMove: closeForm
      });

    };

    // Close Form when Moving Carousel
    var closeForm = function(event) {
      $timeout(function() {
        $scope.closeForm();
      });
    };

    // Destroy Carousel
    var destroyCarousel = function(carouselElement) {
      $(carouselElement).data('owlCarousel').destroy();
    };

    // Show Team Member
    $scope.teamSection.showTeamMember = function(userId) {

    };

    // Show New Invite Form
    $scope.teamSection.newInvite = function() {

    };

    // Show Invites Carousel
    $scope.teamSection.showInvites = function() {
      if ($scope.showInvitesCarousel === true) {
        $scope.closeCarousel();
        return;
      } else {
        $scope.invites = [{type: 'empty'},{type: 'empty'},{type: 'empty'},{type: 'empty'},{type: 'empty'}];
        $scope.showInvitesCarousel = true;
        // slick('.invites');
      }
    };

    // Close Form
    $scope.closeCarousel = function() {
      $scope.showInvitesCarousel = false;
    };

    return User.list().then(function(items) {
      $scope.teamMembers = items.entities;
      $timeout(function(){
        initCarousel('.team');
      });
    });
  }

  DashboardTeamCtrl.$inject = ['$scope', '$timeout', 'User'];
  angular.module('powurApp').controller('DashboardTeamCtrl', DashboardTeamCtrl);

})();
