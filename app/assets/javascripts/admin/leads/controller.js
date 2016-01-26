;(function() {
  'use strict';

  angular.module('powurApp')
    .controller('AdminLeadsCtrl', controller)
    .config(routes);

  controller.$inject = ['$scope', '$rootScope', '$anchorScroll', '$http', '$location', '$routeParams', 'CommonService', '$timeout'];
  function controller($scope, $rootScope, $anchorScroll, $http,  $location, $routeParams, CommonService, $timeout) {
    $scope.redirectUnlessSignedIn();
    $scope.form = {};
    $scope.search = {};
    $scope.templateData = {
      index: {
        title: 'Leads',
        tablePath: 'admin/leads/templates/table.html'
      },
      changeLeadOwner: {
        title: 'Change Lead Owner',
        tablePath: 'admin/leads/templates/change_leads_table.html'
      }
    };

    $scope.fullName = function(user) {
      if (!user) return;
      return user.properties.first_name + ' ' + user.properties.last_name;
    };

    $scope.leadName = function(lead) {
      if (!lead) return;
      return lead.properties.owner.first_name + ' ' + lead.properties.owner.last_name;
    };

    $scope.setNewOwner = function(newOwnerId, leadId) {
      var action = getAction($scope.actions, 'switch_owner');
      $http({
        method: action.method,
        url: action.href,
        params: {
          lead_id: leadId,
          new_owner_id: newOwnerId
        }
      }).success(function(data) {
        if (data.error) {
          $scope.showModal(data.error.message);
        } else {
          $location.path('/admin/leads/');
          $scope.showModal('You\'ve successfully changed the lead owner.');
        }
      });
    };

    $scope.confirm = function(msg, clickAction, arg1, arg2) {
      if (window.confirm(msg)) {
        return $scope.$eval(clickAction)(arg1, arg2);
      }
    };

    // TODO:Have 1 'pagination' fn instead of defining it in every controller
    $scope.pagination = function(direction, path) {
      if (typeof direction === 'undefined') direction = 0;
      var sort;
      var params = {
        page: 1,
        sort: sort,
        limit: 50
      },
      searchQuote;
      if ($scope.index.data) {
        if ($scope.index.data.properties) {
          params.page = $scope.index.data.properties.paging.current_page;
          params.sort = $scope.index.data.properties.sorting.current_sort;
        }
        if ($scope.index.data.searchQuote) {
          searchQuote = $scope.index.data.searchQuote;
          params.search = searchQuote;
        }
        if ($scope.search.string) {
          params.user_search = $scope.search.string;
        }
      }
      params.page += direction;
      return $http({
        method: 'GET',
        url: path || $scope.listPath,
        params: params
      }).success(function(data) {
        $scope.index.data = data;
        $scope.index.data.searchQuote = searchQuote;
        $anchorScroll();
      });
    };

    $scope.search = function() {
      if ($scope.index.data && $scope.index.data.searchQuote) {
        $scope.pagination();
      }
    };

    $scope.clearSearch = function() {
      $timeout(function(){
        if (!$scope.search.string) {
          $scope.pagination();
        }
      });
    };

    $scope.showDetails = function(item) {
      if ($scope.detailView &&
          $scope.detailView.id === item.properties.id) return clearTable();
      $scope.detailView = item.properties;
    };

    function clearTable() {
      $scope.detailView = null;
    }

    $scope.index = {};

    $rootScope.breadcrumbs.push({title: $scope.templateData.index.title});
    this.init($scope, $location);
    this.fetch($scope, $rootScope, $location, $routeParams, CommonService);
  }

  controller.prototype.init = function($scope, $location) {
    // Setting mode based on the url
    if (/\/change-leads$/.test($location.path())) return $scope.mode = 'change-leads';
    if (/\/leads$/.test($location.path())) return $scope.mode = 'index';
  };

  controller.prototype.fetch = function($scope, $rootScope, $location, $routeParams, CommonService) {
    if ($scope.mode === 'index') {
      $scope.pagination(0, $scope.listPath = '/u/leads');
    } else if ($scope.mode === 'change-leads') {
      $scope.pagination(0, $scope.listPath = '/a/users');
      getLead($routeParams.leadId, function(item) {
        $scope.lead = item;
        $scope.actions = item.actions;
      });
    }

    function getLead(leadId, cb) {
      CommonService.execute({
        href: '/u/leads/' + leadId
      }).then(cb);
    }
  };

  routes.$inject = ['$routeProvider'];
  function routes($routeProvider) {
    $routeProvider.
    when('/admin/leads', {
      templateUrl: 'shared/admin/rest/index.html',
      controller: 'AdminLeadsCtrl'
    })
    .when('/admin/leads/:leadId/change-leads', {
      templateUrl: 'admin/leads/templates/change-leads.html',
      controller: 'AdminLeadsCtrl'
    });
  }

  /*
  * Utility Functions
  */

  function getAction(actions, name) {
    for (var i in actions) {
      if (actions[i].name === name) {
        return actions[i];
      }
    }
  }

})();
