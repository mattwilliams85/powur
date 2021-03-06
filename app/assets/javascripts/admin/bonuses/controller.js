;(function() {
  'use strict';

  function AdminBonusesCtrl($scope, $rootScope, $location, $routeParams, $http, CommonService) {
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
      $location.path('/bonus-plans/' + $scope.bonusPlan.id + '/bonuses');
    };

    // Create Bonus Action
    $scope.create = function() {
      if ($scope.bonus) {
        $scope.isSubmitDisabled = true;
        CommonService.execute($scope.formAction, $scope.bonus).then(actionCallback($scope.formAction));
      }
    };

    // Update Bonus Action
    $scope.update = function() {
      if ($scope.bonus) {
        CommonService.execute($scope.formAction, $scope.bonus).then(actionCallback($scope.formAction));
      }
    };

    // Generic Bonus execute() Function
    $scope.execute = function (action, bonus) {
      if (action.name === 'update') {
        $scope.bonus = bonus;
        $location.path('/bonus-plans/' + $scope.bonusPlan.id + '/bonuses/' + bonus.properties.id + '/edit');
      } else if (action.name === 'delete') {
        if (window.confirm('Are you sure you want to delete this bonus?')) {
          CommonService.execute(action, bonus).then(actionCallback(action));
        }
      } else {
        CommonService.execute(action, bonus).then(actionCallback(action));
      }
    };

    function actionCallback(action) {
      var destination = '/bonus-plans/' + $scope.bonusPlan.id + '/bonuses',
          modalMessage = '';
      if (action.name === 'create') {
        destination = ('/bonus-plans/' + $scope.bonusPlan.id + '/bonuses');
        modalMessage = ('You\'ve successfully added a new bonus.');
        $scope.isSubmitDisabled = false;
      } else if (action.name === 'update') {
        destination = ('/bonus-plans/' + $scope.bonusPlan.id + '/bonuses');
        modalMessage = ('You\'ve successfully updated this bonus.');
      } else if (action.name === 'delete') {
        destination = ('/bonus-plans/' + $scope.bonusPlan.id + '/bonuses');
        modalMessage = ('You\'ve successfully deleted this bonus.');
      }

      return CommonService.execute({
        href: '/a/bonus_plans/' + $routeParams.bonusPlanId + '/bonuses.json',
      }).then(function(item) {
        $location.path(destination);
        $scope.bonuses = item.entities;
        $scope.showModal(modalMessage);
      });
    }

    this.init($scope, $location);
    this.fetch($scope, $rootScope, $location, $routeParams, CommonService);
  }

  AdminBonusesCtrl.prototype.init = function($scope, $location){
    // Set mode based on URL
    $scope.mode = 'show';
    if (/\/bonuses$/.test($location.path())) return $scope.mode = 'index';
    if (/\/new$/.test($location.path())) return $scope.mode = 'new';
    if (/\/edit$/.test($location.path())) return $scope.mode = 'edit';
  };

  AdminBonusesCtrl.prototype.fetch = function($scope, $rootScope, $location, $routeParams, CommonService) {
    if ($scope.mode === 'index') {
      getBonusPlan();

      CommonService.execute({
        href: '/a/bonus_plans/' + $routeParams.bonusPlanId + '/bonuses.json',
      }).then(function(items) {
        $scope.bonuses = items.entities;

        // Breadcrumbs: Bonus Plans / Bonus Plan Name / Update Bonus Plan
        $rootScope.breadcrumbs.push({title: 'Bonus Plans', href:'/admin/bonus-plans'});
        $rootScope.breadcrumbs.push({title: $scope.bonusPlan.name, href: '/admin/bonus-plans/' + $scope.bonusPlan.id});
        $rootScope.breadcrumbs.push({title: 'Bonuses'});
      });

    } else if ($scope.mode === 'show') {

    } else if ($scope.mode === 'new') {
      getBonusPlan();

      CommonService.execute({
        href: '/a/bonus_plans/' + $routeParams.bonusPlanId + '/bonuses.json',
      }).then(function(item){
        $scope.bonus = {};
        $scope.formAction = $scope.getAction(item.actions, 'create');

        // Breadcrumbs: Bonus Plans / Bonus Plan Name / Update Bonus Plan
        $rootScope.breadcrumbs.push({title: 'Bonus Plans', href:'/admin/bonus-plans'});
        $rootScope.breadcrumbs.push({title: $scope.bonusPlan.name, href: '/admin/bonus-plans/' + $scope.bonusPlan.id});
        $rootScope.breadcrumbs.push({title: 'Bonuses', href: '/admin/bonus-plans/' + $scope.bonusPlan.id + '/bonuses'});
        $rootScope.breadcrumbs.push({title: 'New Bonus'});
      });

    } else if ($scope.mode === 'edit') {
      getBonusPlan();

      CommonService.execute({
        href: '/a/bonuses/' + $routeParams.bonusId + '.json',
      }).then(function(item) {
        $scope.bonus = item.properties;
        $scope.formAction = $scope.getAction(item.actions, 'update');

        var fields = $scope.formAction.fields;
        // Holy Loop to fill form with existing values 🙌
        for (var i in fields) {
          $scope.bonus[fields[i].name] = fields[i].value;
        }

        // Breadcrumbs: Bonus Plans / Bonus Plan Name / Update Bonus Plan
        $rootScope.breadcrumbs.push({title: 'Bonus Plans', href:'/admin/bonus-plans'});
        $rootScope.breadcrumbs.push({title: $scope.bonusPlan.name, href: '/admin/bonus-plans/' + $scope.bonusPlan.id});
        $rootScope.breadcrumbs.push({title: 'Bonuses', href: '/admin/bonus-plans/' + $scope.bonusPlan.id + '/bonuses'});
        $rootScope.breadcrumbs.push({title: 'Update Bonus'});
      });
    }

    function getBonusPlan() {
      CommonService.execute({
        href: '/a/bonus_plans/' + $routeParams.bonusPlanId + '.json'
      }).then(function(item) {
        $scope.bonusPlan = item.properties;
      });
    }
  };

  AdminBonusesCtrl.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$http', 'CommonService'];
  angular.module('powurApp').controller('AdminBonusesCtrl', AdminBonusesCtrl);
})();
