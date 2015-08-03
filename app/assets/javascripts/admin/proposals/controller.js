;(function() {
  'use strict';

  function AdminProposalsCtrl($scope, $rootScope, $location, $routeParams, $anchorScroll, $http, AdminProposal) {
    $scope.redirectUnlessSignedIn();

    $scope.backToIndex = function() {
      $location.path('/admin/proposals/');
    };

    this.init($scope, $location);
    this.fetch($scope, $rootScope, $location, $routeParams, AdminProposal);
  }

  AdminProposalsCtrl.prototype.init = function($scope, $location) {
    // Setting mode based on the url
    $scope.mode = 'show';
    if (/\/proposals$/.test($location.path())) return $scope.mode = 'index';
    if (/\/new$/.test($location.path())) return $scope.mode = 'new';
    if (/\/edit$/.test($location.path())) return $scope.mode = 'edit';
  };

  AdminProposalsCtrl.prototype.fetch = function($scope, $rootScope, $location, $routeParams, AdminProposal) {
    if ($scope.mode === 'index') {
      AdminProposal.list().then(function(items) {
        $scope.users = items.entities;

        // Breadcrumbs: Proposals
        $rootScope.breadcrumbs.push({title: 'Proposals'});
      });

    } else if ($scope.mode === 'new') {

    } else if ($scope.mode === 'show') {
      AdminProposal.get($routeParams.proposalId).then(function(item) {
        $scope.user = item.properties;

        // Breadcrumbs: Proposals / View Lead
        $rootScope.breadcrumbs.push({title: 'Proposals', href: '/admin/proposals'});
        $rootScope.breadcrumbs.push({title: 'View Lead'});

      });

    } else if ($scope.mode === 'edit') {
      AdminProposal.get($routeParams.proposalId).then(function(item) {
        $scope.user = item.properties;

        // Breadcrumbs: Proposals / Update Lead
        $rootScope.breadcrumbs.push({title: 'Proposals', href: '/admin/proposals'});
        $rootScope.breadcrumbs.push({title: 'Update Lead'});

      });
    }
  };

  AdminProposalsCtrl.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$anchorScroll', '$http', 'AdminProposal'];
  angular.module('powurApp').controller('AdminProposalsCtrl', AdminProposalsCtrl);

})();
