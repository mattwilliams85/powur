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

    $scope.pagination = function(direction) {
      var page = 1;
      if ($scope.indexData) {
        page = $scope.indexData.properties.paging.current_page;
      }
      page += direction;
      return CommonService.execute({
        href: '/a/users.json?has_rank=true&page=' + page
      }).then(function(data) {
        $scope.indexData = data;
        $anchorScroll();
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
