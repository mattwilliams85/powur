;(function() {
  'use strict';

  function DashboardCtrl($scope, $rootScope, $location, $timeout, UserProfile, CommonService) {
    $scope.redirectUnlessSignedIn();

    //Fetch Profile
    UserProfile.get().then(function(user) {
      $rootScope.currentUser = user;
      $scope.fetchGoals();
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
       
        // if ($scope.currentUser.organicRank > 0) {
        //   CommonService.execute({
        //     href: '/u/ranks/' + $scope.currentUser.organicRank + '.json'
        //   }).then(function(data) {
        //     $scope.currentUser.organicRank = data.properties.title;
        //   });
        // } else {
        //   $scope.currentUser.organicRank = 'advocate';
        // }
      });
    };

    $scope.onEnd = function(){
      $timeout(function(){
        $('.bar').removeClass('hold')
        $('.progress-text').fadeIn('slow');
      }, 1000);
    };


    $scope.calculateProgress = function(requirement) {
      if (!requirement) return;
      var percentage = 2;
      var userTotal;
      var orderTotals = $scope.goals.entities[3].entities[0].properties;
      
      if (requirement.properties.event_type === 'personal_sales') { 
        if (requirement.properties.time_span === 'Lifetime') { 
          userTotal = orderTotals.personal_lifetime;
        } else {
          userTotal = orderTotals.personal;
        }
        $scope.goals.personal = userTotal + " / " + requirement.properties.quantity;
        percentage = userTotal / requirement.properties.quantity  * 100
      } else if (requirement.properties.event_type === 'group_sales') {
        if (requirement.properties.time_span === 'Lifetime') { 
          userTotal = orderTotals.group_lifetime;
        } else {
          userTotal = orderTotals.group;
        }
        $scope.goals.group = userTotal + " / " + requirement.properties.quantity;
        percentage = userTotal / requirement.properties.quantity * 100
      }
      else {
        // Match Course
        var courses = $scope.goals.entities[2].entities;
        if (!courses.length) {
          $scope.courseLinking = true;
          $scope.goals.courseState = 'not enrolled';
          $scope.goals.courseId = requirement.properties.product_id;
        } else {
          for (var i = 0; i < courses.length; i++) {
            if (courses[i].properties.product_id === requirement.properties.product_id) {
              if (courses[i].properties.state === 'enrolled') {
                percentage = 33;
                $scope.goals.courseState = 'enrolled';
              } else if (courses[i].properties.state === 'started') {
                percentage = 66;
                $scope.goals.courseState = 'started';
              } else if (courses[i].properties.state === 'completed') {
                percentage = 100;
                $scope.goals.courseState = 'completed';
              }
            }
          }
        }
      }
      if(percentage === 0) percentage = 2;
      return percentage + '%';
    };


    $scope.socialQuote = '"Don\'t try to fight the existing reality, build a new model that makes the old model obsolete" - Buckminster Fuller';
  }

  DashboardCtrl.$inject = ['$scope', '$rootScope', '$location', '$timeout', 'UserProfile', 'CommonService'];
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
