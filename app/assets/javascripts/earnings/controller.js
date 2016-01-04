/* jshint camelcase: false */
;(function() {
  'use strict';

  function EarningsCtrl($scope, $rootScope, $location, $http, $timeout, UserProfile, CommonService, Utility) {
    $scope.redirectUnlessSignedIn();
    $scope.payPeriodFilters = [ { value: 'monthly', title: 'Monthly' },
                                { value: 'weekly', title: 'Weekly' } ];
    $scope.selectedFilter = { span: 'monthly' };
    $scope.animating = false;

    UserProfile.get().then(function(data) {
      $scope.currentUser = data.properties;

      $scope.requestEarnings();
    });

    $scope.userProfile = {};
    $http({
      method: 'GET',
      url: '/u/profile'
    }).success(function(data) {
      $scope.userProfile = data.properties;
    });

    $scope.requestEarnings = function() {
      $http({
        method: 'GET',
        url: '/u/users/'+$scope.currentUser.id+'/pay_periods',
        params: {
          time_span: $scope.selectedFilter.span
        }
      }).success(function(data){
        $scope.payPeriods = data.entities;
      });
    };

    $scope.showDetails = function(item) {
      $scope.animating = true;
      $timeout(function(){ $scope.animating = false; },300);
      if ($scope.payPeriod &&
          $scope.payPeriod.id === item.properties.id) return clearTable();
      CommonService.execute(item.links[0]).then(function success(data) {
        $scope.payPeriod = data.properties;
        $scope.totals = data.entities[0].entities;
        $scope.details = data.entities[1].entities;
        $scope.grandTotal = data.entities[1].properties.grand_total;
      });
    };

    $scope.lastType = null;

    $scope.subTotal = function(item, index) {
      if (item.properties.bonus === $scope.lastType &&
         index !== $scope.details.length  ||
         index === 0) {
        $scope.lastType = item.properties.bonus;
        return false;
      }
      $scope.lastType = item.properties.bonus;
      return true;
    };

    $scope.lastTotal = function(index) {
      if (index === $scope.details.length - 1) return true;
    };

    $scope.findTotal = function(index, type) {
      if (index !== 0) index -= 1;
      var total = Utility.findBranch($scope.totals, {'bonus': $scope.details[index].properties.bonus});
      if (type === 'name') return total.bonus;
      return total.bonus_total;
    };


    function clearTable() {
      $scope.payPeriod = null;
      $scope.details = null;
    }

    $scope.findKeyDate = function(item) {
      var lead = item.properties.lead;
      if (!lead) return;
      if (lead.installed_at) return lead.installed_at;
      if (lead.contracted_at) return lead.contracted_at;
      if (lead.closed_won_at) return lead.closed_won_at;
      return lead.converted_at;
    };
  }

  EarningsCtrl.$inject = ['$scope', '$rootScope', '$location', '$http', '$timeout', 'UserProfile', 'CommonService', 'Utility'];
  angular.module('powurApp').controller('EarningsCtrl', EarningsCtrl);
})();
