;(function() {
  'use strict';

  function AdminQuotesCtrl($scope, $rootScope, $location, $routeParams, $anchorScroll, $http, AdminQuote) {
    $scope.redirectUnlessSignedIn();

    $scope.backToIndex = function() {
      $location.path('/admin/quotes/');
    };

    this.init($scope, $location);
    this.fetch($scope, $rootScope, $location, $routeParams, AdminQuote);
  }

  AdminQuotesCtrl.prototype.init = function($scope, $location) {
    // Setting mode based on the url
    $scope.mode = 'show';
    if (/\/users$/.test($location.path())) return $scope.mode = 'index';
    if (/\/new$/.test($location.path())) return $scope.mode = 'new';
    if (/\/edit$/.test($location.path())) return $scope.mode = 'edit';
  };

  AdminQuotesCtrl.prototype.fetch = function($scope, $rootScope, $location, $routeParams, AdminQuote) {
    if ($scope.mode === 'index') {
      AdminQuote.list().then(function(items) {
        $scope.users = items.entities;

        // Breadcrumbs: Proposals
        $rootScope.breadcrumbs.push({title: 'Proposals'});
      });

    } else if ($scope.mode === 'new') {

    } else if ($scope.mode === 'show') {
      AdminQuote.get($routeParams.quoteId).then(function(item) {
        $scope.user = item.properties;

        // Breadcrumbs: Proposals / View Quote
        $rootScope.breadcrumbs.push({title: 'Proposals', href: '/admin/quotes'});
        $rootScope.breadcrumbs.push({title: 'View Quote'});

      });

    } else if ($scope.mode === 'edit') {
      AdminQuote.get($routeParams.quoteId).then(function(item) {
        $scope.user = item.properties;

        // Breadcrumbs: Proposals / Update Quote
        $rootScope.breadcrumbs.push({title: 'Proposals', href: '/admin/quotes'});
        $rootScope.breadcrumbs.push({title: 'Update Quote'});

      });
    }
  };

  AdminQuotesCtrl.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$anchorScroll', '$http', 'AdminQuote'];
  angular.module('powurApp').controller('AdminQuotesCtrl', AdminQuotesCtrl);

})();
