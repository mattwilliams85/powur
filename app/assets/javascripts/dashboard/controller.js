;(function() {
  'use strict';

  function DashboardCtrl($scope, $rootScope, $location, $timeout, UserProfile, CommonService, Utility) {
    $scope.redirectUnlessSignedIn();

    //Fetch Profile
    UserProfile.get().then(function(data) {
      $rootScope.currentUser = data.properties;
      $scope.fetchGoals();
      kpiHeaders();
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

    function kpiHeaders() {
      // Populate KPI Headers
      CommonService.execute({
        href: 'u/kpi_metrics.json'
      }).then(function(data) {
        $rootScope.currentUser.metrics = data;
      });
    }

    // Fix for scope inheritance issues (relating to Proposals search/sort):
    $scope.customerSection = {};
    $scope.teamSection = {};
    $scope.progress = {};

    $scope.legacyImagePaths = legacyImagePaths;

    $scope.loadMoreNews = function() {
      var nextPage = $scope.currentNewsPage + 1;
      CommonService.execute({
        href: '/u/news_posts.json?page=' + nextPage
      }).then(function(news_posts) {
        for (var i in news_posts.entities) {
          $scope.news.push(news_posts.entities[i]);
        }
        $scope.currentNewsPage = news_posts.properties.paging.current_page;
        if (news_posts.properties.paging.page_count > news_posts.properties.paging.current_page) {
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

    //Fetch News Posts
    CommonService.execute({
      href: '/u/news_posts.json'
    }).then(function(news_posts) {
      $scope.news = news_posts.entities;
      $scope.currentNewsPage = news_posts.properties.paging.current_page;
      if (news_posts.properties.paging.page_count > news_posts.properties.paging.current_page) {
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
        course_enrollment: function() {
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
