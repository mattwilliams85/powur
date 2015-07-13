;(function() {
  'use strict';

  function AdminInvitesCtrl($scope, $rootScope, $anchorScroll, CommonService) {
    $scope.redirectUnlessSignedIn();

    $scope.templateData = {
      index: {
        title: 'Invites',
        tablePath: 'admin/invites/templates/table.html'
      }
    };

    // TODO: Have one 'pagination' function instead of defining it in every controller
    $scope.pagination = function(direction) {
      var page = 1,
          sort;
      if ($scope.index.data) {
        page = $scope.index.data.properties.paging.current_page;
        sort = $scope.index.data.properties.sorting.current_sort;
      }
      page += direction;
      return CommonService.execute({
        href: '/a/users/invites?with_purchases=true',
        params: {
          page: page,
          sort: sort
        }
      }).then(function(data) {
        $scope.index.data = data;
        $anchorScroll();
      });
    };

    $scope.updateAvailableInvites = function(item) {
      var data = {invites: item.properties.available_invites};
      CommonService.execute({
        href: '/a/users/' + item.properties.id + '/invites.json',
        method: 'PATCH',
      }, data).then(function(data) {
        if (data.error) {
          $scope.showModal('There was an error updating this user\'s available invites.');
        }
        item.properties.lifetime_invites_count = data.properties.lifetime_invites_count;
      });
    };

    this.init($scope);
    this.fetch($scope, $rootScope);
  }

  AdminInvitesCtrl.prototype.init = function($scope) {
    $scope.mode = 'index';
  };

  AdminInvitesCtrl.prototype.fetch = function($scope, $rootScope) {
    if ($scope.mode === 'index') {
      $rootScope.breadcrumbs.push({title: 'Invites'});
      $scope.index = {};
      $scope.pagination(0);
    }
  };

  // Utility Functions
  function getAction(actions, name) {
    for (var i in actions) {
      if (actions[i].name === name) {
        return actions[i];
      }
    }
    return;
  }

  AdminInvitesCtrl.$inject = ['$scope', '$rootScope', '$anchorScroll', 'CommonService'];
  angular.module('powurApp').controller('AdminInvitesCtrl', AdminInvitesCtrl);
})();
