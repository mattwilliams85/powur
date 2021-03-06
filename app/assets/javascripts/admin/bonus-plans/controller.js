;(function() {
  'use strict';

  function AdminBonusPlansCtrl($scope, $rootScope, $location, $routeParams, $http, CommonService) {
    $scope.redirectUnlessSignedIn();

    // Utility Functions
    $scope.getAction = function (actions, name) {
      for (var i in actions) {
        if (actions[i].name === name) {
          return actions[i];
        }
      }
      return;
    };

    $scope.cancel = function() {
      if ($scope.mode === 'new') {
        $location.path('/bonus-plans');
      } else {
        $location.path('/bonus-plans/' + $scope.bonusPlan.id);
      }
    };

    // Create Bonus Plan Action
    $scope.create = function() {
      if ($scope.bonusPlan) {
        $scope.isSubmitDisabled = true;
        CommonService.execute($scope.formAction, $scope.bonusPlan).then(actionCallback($scope.formAction));
      }
    };

    // Update Bonus Plan Action
    $scope.update = function() {
      if ($scope.bonusPlan) {
        CommonService.execute($scope.formAction, $scope.bonusPlan).then(actionCallback($scope.formAction));
      }
    };

    // Delete Action
    $scope.delete = function(bonusPlanObj) {
      var action = $scope.getAction(bonusPlanObj.actions, 'delete');
      if (action) {
        $scope.execute(action, bonusPlanObj);
      }
    };

    // Generic Bonus Plan execute() Function
    $scope.execute = function (action, bonusPlanObj) {
      if (action.name === 'update') {
        $scope.bonusPlan = bonusPlanObj.properties;
        $location.path('/bonus-plans/' + $scope.bonusPlan.id + '/edit');
      } else if (action.name === 'delete') {
        if (window.confirm('Are you sure you want to delete this bonus plan?')) {
          CommonService.execute(action, bonusPlanObj).then(actionCallback(action));
        }
      } else {
        CommonService.execute(action, bonusPlanObj).then(actionCallback(action));
      }
    };

    var actionCallback = function(action) {
      var destination = '/bonus-plans',
          modalMessage = '';
      if (action.name === 'create') {
        destination = ('/bonus-plans');
        modalMessage = ('You\'ve successfully added a new bonus plan.');
        $scope.isSubmitDisabled = false;
      } else if (action.name === 'update') {
        destination = ('/bonus-plans/' + $scope.bonusPlan.id);
        modalMessage = ('You\'ve successfully updated this bonus plan.');
      } else if (action.name === 'delete') {
        destination = ('/bonus-plans');
        modalMessage = ('You\'ve successfully deleted this bonus plan.');
      }

      return CommonService.execute({
        href: '/a/bonus_plans.json'
      }).then(function(item) {
        $location.path(destination);
        $scope.bonusPlans = item.entities;
        $scope.showModal(modalMessage);
      });
    };

    this.init($scope, $location);
    this.fetch($scope, $rootScope, $location, $routeParams, CommonService);
  }

  AdminBonusPlansCtrl.prototype.init = function($scope, $location){
    // Set mode based on URL
    $scope.mode = 'show';
    if (/\/bonus-plans$/.test($location.path())) return $scope.mode = 'index';
    if (/\/new$/.test($location.path())) return $scope.mode = 'new';
    if (/\/edit$/.test($location.path())) return $scope.mode = 'edit';
  };

  AdminBonusPlansCtrl.prototype.fetch = function($scope, $rootScope, $location, $routeParams, CommonService) {
    if ($scope.mode === 'index') {
      CommonService.execute({
        href: '/a/bonus_plans.json'
      }).then(function(items) {
        $scope.bonusPlans = items.entities;

        // Breadcrumbs: Bonus Plans
        $rootScope.breadcrumbs.push({title: 'Bonus Plans'});
      });

    } else if ($scope.mode === 'show') {
      CommonService.execute({
        href: '/a/bonus_plans/' + $routeParams.bonusPlanId + '.json'
      }).then(function(item) {
        $scope.bonusPlan = item.properties;
        $scope.bonuses = [];
        CommonService.execute({
          href: item.entities[0].href + '.json',
        }).then(function(bonuses) {
          $scope.bonuses = bonuses.entities;
        });

        // Breadcrumbs: Bonus Plans / Bonus Plan Name
        $rootScope.breadcrumbs.push({title: 'Bonus Plans', href:'/admin/bonus-plans'});
        $rootScope.breadcrumbs.push({title: $scope.bonusPlan.name});
      });

    } else if ($scope.mode === 'new') {
      CommonService.execute({
        href: '/a/bonus_plans.json'
      }).then(function(item){
        $scope.bonusPlan = {};
        $scope.formAction = $scope.getAction(item.actions, 'create');

        // Breadcrumbs: Bonus Plans / New Bonus Plan
        $rootScope.breadcrumbs.push({title: 'Bonus Plans', href: '/admin/bonus-plans'});
        $rootScope.breadcrumbs.push({title: 'New Bonus Plan'});
      });

    } else if ($scope.mode === 'edit') {
      CommonService.execute({
        href: '/a/bonus_plans/' + $routeParams.bonusPlanId + '.json'
      }).then(function(item) {
        $scope.bonusPlan = item.properties;
        $scope.bonusPlanObj = item;
        $scope.formAction = $scope.getAction(item.actions, 'update');

        // Determine whether the bonus plan can be deleted
        if ($scope.bonusPlan.active === true) {
          $scope.canBeDeleted = false;
        } else {
          $scope.canBeDeleted = true;
        }

        var fields = $scope.formAction.fields;
        // Holy Loop to fill form with existing values 🙌
        for (var i in fields) {
          $scope.bonusPlan[fields[i].name] = fields[i].value;
        }

        // Breadcrumbs: Bonus Plans / Bonus Plan Name / Update Bonus Plan
        $rootScope.breadcrumbs.push({title: 'Bonus Plans', href:'/admin/bonus-plans'});
        $rootScope.breadcrumbs.push({title: $scope.bonusPlan.name, href: '/admin/bonus-plans/' + $scope.bonusPlan.id});
        $rootScope.breadcrumbs.push({title: 'Update Bonus Plan'});
      });
    }
  };

  AdminBonusPlansCtrl.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$http', 'CommonService'];
  angular.module('powurApp').controller('AdminBonusPlansCtrl', AdminBonusPlansCtrl);
})();
