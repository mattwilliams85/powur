;(function() {
  'use strict';

  function DashboardTeamCtrl($scope, $timeout, User) {
    $scope.redirectUnlessSignedIn();

    // Initialize slick carousel
    function slick(elementToSlick) {
      console.log("slicking " + elementToSlick)
      $(elementToSlick).on('init', function(event, slick) {
        slick.refresh = slick.unfilterSlides;
      });
      $(elementToSlick).slick({
        swipe: true,
        dots: false,
        infinite: true,
        speed: 300,
        slidesToShow: 5,
        slidesToScroll: 5,
        responsive: [
          {
            breakpoint: 1024,
            settings: {
              slidesToShow: 4,
              slidesToScroll: 4,
            }
          },
          {
            breakpoint: 768,
            settings: {
              slidesToShow: 3,
              slidesToScroll: 3
            }
          },
          {
            breakpoint: 640,
            settings: {
              slidesToShow: 2,
              slidesToScroll: 2
            }
          }
        ]
      });
    }

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
        slick('.invites');
      }
    };

    // Close Form
    $scope.closeCarousel = function() {
      $scope.showInvitesCarousel = false;
    };

    return User.list().then(function(items) {
      $scope.teamMembers = items.entities;
      $timeout(function(){
        slick('.team');
        slick('.invites');
      }, 1000);
    });
  }

  DashboardTeamCtrl.$inject = ['$scope', '$timeout', 'User'];
  angular.module('powurApp').controller('DashboardTeamCtrl', DashboardTeamCtrl);

})();
