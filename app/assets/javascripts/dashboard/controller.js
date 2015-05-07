;(function() {
  'use strict';

  function DashboardCtrl($scope, $location, UserProfile, Notification) {
    $scope.redirectUnlessSignedIn();

    // Fix for scope inheritance issues (relating to Proposals search/sort):
    $scope.customerSection = {};
    $scope.teamSection = {};

    $scope.dashboardTeamIcon = legacyImagePaths.dashboardTeamIcon;
    $scope.dashboardCustomersIcon = legacyImagePaths.dashboardCustomersIcon;
    $scope.dashboardKPIIcon = legacyImagePaths.dashboardKPIIcon;

    $scope.loadMoreNews = function() {
      var nextPage = $scope.currentNewsPage + 1;
      Notification.list({page: nextPage}).then(function(notifications) {
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

    Notification.list().then(function(notifications) {
      $scope.news = notifications.entities;
      $scope.currentNewsPage = notifications.properties.paging.current_page;
      if (notifications.properties.paging.page_count > notifications.properties.paging.current_page) {
        $scope.moreNews = true;
      } else {
        $scope.moreNews = false;
      }
    });

    UserProfile.get().then(function(user) {
      $scope.currentUser = user;
      $scope.goals = { personalPercent: 100, groupPercent: 20, badge: legacyImagePaths.goalsBadge };
    });
  }

  DashboardCtrl.$inject = ['$scope', '$location', 'UserProfile', 'Notification'];
  angular.module('powurApp').controller('DashboardCtrl', DashboardCtrl);
})();
