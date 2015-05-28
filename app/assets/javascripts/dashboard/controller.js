;(function() {
  'use strict';

  function DashboardCtrl($scope, $location, $timeout, UserProfile, CommonService) {
    $scope.redirectUnlessSignedIn();

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

    //Fetch Profile
    UserProfile.get().then(function(user) {
      $scope.currentUser = user;
      $scope.fetchGoals();
    });

    //Fetch goals
    $scope.fetchGoals = function() {
      CommonService.execute({
        href: '/u/users/' + $scope.currentUser.id + '/goals.json'
      }).then(function(data) {
        $scope.goals = data;
        $scope.goals.badge = $scope.legacyImagePaths.goalsBadges[data.properties.next_rank];
        $scope.goals.requirements = data.entities[1].entities;
      });
    };

    $scope.onEnd = function(){
      $timeout(function(){
        $('.bar').removeClass('hold')
        $('.progress-text').fadeIn('slow');
      }, 1000);
    };


    $scope.calculateProgress = function(requirement) {
      var percentage;
      if (requirement.properties.event_type === 'personal_sales') { 

      } else if (requirement.properties.event_type === 'group_sales') {

      }
      else {
        // Match Course
        var courses = $scope.goals.entities[2].entities;
        if (!courses.length) {
          percentage = 1;
          $scope.courseLinking = true;
        }
        for (var i = 0; i < courses.length; i++) {
          if (courses[i].properties.product_id === requirement.properties.product_id) {

            if (courses[i].properties.state === 'enrolled') {
              percentage = 25;
              $scope.goals.course = 'enrolled';
            } else if (courses[i].properties.state === 'started') {
              percentage = 50;
              $scope.goals.course = 'started';
            } else if (courses[i].properties.state === 'completed') {
              percentage = 75;
              $scope.goals.course = 'completed';
            } else {
              percentage = 1;
            }
          }
        };
      }
      return percentage + '%';
    };


    $scope.socialQuote = '"Don\'t try to fight the existing reality, build a new model that makes the old model obsolete" - Buckminster Fuller';
  }

  DashboardCtrl.$inject = ['$scope', '$location', '$timeout', 'UserProfile', 'CommonService'];
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
