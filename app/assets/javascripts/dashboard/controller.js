;(function() {
  'use strict';

  function DashboardCtrl($scope, $rootScope, $location, $timeout, UserProfile, CommonService, Utility) {
    $scope.redirectUnlessSignedIn();
    //Fetch Profile
    UserProfile.get().then(function(data) {
      $rootScope.currentUser = data.properties;

      if ($rootScope.currentUser.notification) {
        $rootScope.currentUser.notification = Autolinker.link($rootScope.currentUser.notification);
      }

      $scope.actions = data.actions;
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
    $scope.leadPipelineSection = {};
    $scope.teamSection = {};
    $scope.progress = {};

    $scope.legacyImagePaths = legacyImagePaths;

    $scope.closeNotification = function() {
      if (!$scope.currentUser.notification) return;
      var action = getAction($scope.actions, 'update_profile');
      CommonService.execute(action, {user: {mark_notifications_as_read: '1'}});
      $scope.currentUser.notification = null;
    };

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
      rank = rank || 0;
      return $scope.legacyImagePaths.goalsBadges[rank];
    };

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


    $scope.fetchGoals = function() {
      CommonService.execute({
        href: '/u/users/' + $scope.currentUser.id + '/goals'
      }).then(function(data) {
        if (data) {
          $scope.goals = data;
          $scope.requirements = Utility.findBranch(data.entities, {'rel': 'goals-requirements'}).entities;
          $scope.goals.badge = $scope.badgePath(data.properties.next_rank);
          $scope.progress = {};
          $scope.rank_list = $scope.goals.properties['rank_list=']
          calculateProgress($scope.requirements);
        }
      });
    };

    $scope.onEnd = function(){
      $timeout(function(){
        $('.bar').removeClass('hold');
        $('.progress-text').fadeIn('slow');
      }, 1000);
    };

    function calculateProgress(requirements) {
      for (var i = 0; i < requirements.length; i++) {
        var event_type = requirements[i].properties.event_type;
        var goal = Utility.findBranch($scope.goals, { event_type: event_type });
        goal.quantity = goal.quantity || 1;
        if (goal.progress > goal.quantity) goal.progress = goal.quantity;
        goal.percentage = ((goal.progress / goal.quantity) * 100);
        goal = statusText(i, goal);

        $scope.progress[i] = goal;
      }
    }

    function statusText(i, goal) {
      if (goal.purchase) {
        if (goal.progress) {
          goal.status = 'Course Complete';
        } else {
          goal.status = 'Course Incomplete';
        }
      } else {
        goal.product = goal.event_type.split('_').join(' ');
        goal.status = goal.progress + ' / ' + goal.quantity;
      }
      return goal;
    }
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

  /**
   * Utility functions
   */
  function getAction(actions, name) {
    for (var i in actions) {
      if (actions[i].name === name) {
        return actions[i];
      }
    }
    return;
  }

})();
