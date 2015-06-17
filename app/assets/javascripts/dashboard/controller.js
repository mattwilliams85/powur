;(function() {
  'use strict';

  function DashboardCtrl($scope, $rootScope, $location, $timeout, UserProfile, CommonService, Utility) {
    $scope.redirectUnlessSignedIn();

    $rootScope.isTabClickable = false;

    //Fetch Profile
    UserProfile.get().then(function(user) {
      $rootScope.currentUser = user;
      $scope.fetchGoals();

      if (user.organic_rank) {
        $rootScope.isTabClickable = true;
      }

      // Logic for showing Powur Beta Dashboard Overview Video
      if (user.watched_intro === false) {
        $scope.showVideoModal($scope.legacyImagePaths.betaDashboardVideo);
        UserProfile.update({user: {watched_intro: true}});
      }

      // Logic for showing link to Powur Beta Dashboard Overview Video
      $scope.showBetaDashboardVideoLink = true;

    });

    // Populate Social Media Quote
    CommonService.execute({
      href: 'u/social_media_posts.json'
    }).then(function(item) {
      if (item.entities.length) {
        $scope.socialQuote = item.entities[0].properties.content;
      } else {
        return;
      }
    });

    // Fix for scope inheritance issues (relating to Proposals search/sort):
    $scope.customerSection = {};
    $scope.teamSection = {};
    $scope.progress = {};

    $scope.legacyImagePaths = legacyImagePaths;

    $scope.loadMoreNews = function() {
      var nextPage = $scope.currentNewsPage + 1;
      CommonService.execute({
        href: '/u/notifications.json?page=' + nextPage
      }).then(function(notifications) {
        for (var i in notifications.entities) {
          $scope.news.push(notifications.entities[i]);
        }
        $scope.currentNewsPage = notifications.properties.paging.current_page;
        if (notifications.properties.paging.page_count > notifications.properties.paging.current_page) {
          $scope.moreNews = true;
        } else {
          $scope.moreNews = false;
        }
      });
    };

    //Create Badge URL
    $scope.badgePath = function(rank) {
      rank = rank || 1;
      return $scope.legacyImagePaths.goalsBadges[rank];
    }

    //Fetch Notifications
    CommonService.execute({
      href: '/u/notifications.json'
    }).then(function(notifications) {
      $scope.news = notifications.entities;
      $scope.currentNewsPage = notifications.properties.paging.current_page;
      if (notifications.properties.paging.page_count > notifications.properties.paging.current_page) {
        $scope.moreNews = true;
      } else {
        $scope.moreNews = false;
      }
    });


    //Fetch goals
    $scope.fetchGoals = function() {
      CommonService.execute({
        href: '/u/users/' + $scope.currentUser.id + '/goals'
      }).then(function(data) {
        if (data != 0) {
          $scope.goals = data;
          $scope.goals.requirements = data.entities[1].entities;
          $scope.goals.badge = $scope.badgePath(data.properties.next_rank)
        }
      });
    };

    $scope.onEnd = function(){
      $timeout(function(){
        $('.bar').removeClass('hold');
        $('.progress-text').fadeIn('slow');
      }, 1000);
    };

    $scope.calculateProgress = function(requirement) {
      if (!requirement) return;

      var event_type = Utility.searchObjVal(requirement, "event_type")
      var time_span = Utility.searchObjVal(requirement, "time_span")
      var quantity = Utility.searchObjVal(requirement, "quantity")
      $scope.courseState = Utility.searchObjVal($scope.goals, "state")


      var salesTypes = {
        personal_sales: function() {
          if (time_span === 'Lifetime') {
            return Utility.searchObjVal($scope.goals, "personal_lifetime");
          } else {
            return Utility.searchObjVal($scope.goals, "personal");
          }
        },
        group_sales: function() {
          if (time_span === 'Lifetime') {
            return Utility.searchObjVal($scope.goals, "group_lifetime")
          } else {
            return Utility.searchObjVal($scope.goals, "group")
          }
        },
        course_completion: function() {
          quantity = 100;
          $scope.goals.courseId = Utility.searchObjVal(requirement, "product_id")
          if (!$scope.courseState) return 0;

          if ($scope.courseState === 'enrolled') {
            return 33;
          } else if ($scope.courseState === 'started') {
            return 66;
          } else {
            return 100;
          }
        },
        default: function() { return }
      };

      var setRequirement = salesTypes[event_type] || salesTypes['default'];
      var result = setRequirement();

      $scope.goals[event_type] = result + " / " + quantity;
      if (!result || !quantity) return '2%';
      return (result / quantity  * 100) + '%';
    };

    $scope.showVideoModal = function(videoUrl) {
      var domElement =
        '<div class=\'reveal-modal\' data-options="close_on_background_click:false" data-reveal>' +
        '<h3>' + 'Powur Beta Dashboard Overview' + '</h3>' +
        '<video width="100%" autoplay controls>' +
        '<source src="' + videoUrl + '" type="video/mp4">' +
        '</video>' +
        '<a class=\'close-reveal-modal\'>&#215;</a>' +
        '</div>';
      $(domElement).foundation('reveal', 'open');
    };

  }

  DashboardCtrl.$inject = ['$scope', '$rootScope', '$location', '$timeout', 'UserProfile', 'CommonService', 'Utility'];
  angular.module('powurApp').controller('DashboardCtrl', DashboardCtrl)
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
