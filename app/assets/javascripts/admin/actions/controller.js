;(function() {
  'use strict';

  function AdminActionsCtrl($scope, $rootScope, $location, $routeParams, $anchorScroll, $http, CommonService) {
    $scope.redirectUnlessSignedIn();

    $scope.templateData = {
      index: {
        title: 'Powur-Move Actions',
        tablePath: 'admin/actions/templates/table.html',
        links: [
          {href: '/admin/powur-move/new', text: 'New Power Move'}
        ]
      },
      new: {
        title: 'New Powur-Move',
        formPath: 'admin/actions/templates/form.html'
      },
      edit: {
        title: 'Edit Powur-Move',
        formPath: 'admin/actions/templates/form.html'
      }
    };

    $scope.cancel = function() {
      $location.path('/admin/powur-move');
    };

    $scope.save = function() {
      if ($scope.updateAction) {
        $scope.isSubmitDisabled = true;
        if ($scope.updateAction.stage === 'pre') {
          $scope.updateAction.sales_status = '';
          $scope.updateAction.opportunity_stage = '';
          $scope.updateAction.lead_status = ''
        } else {
          $scope.updateAction.data_status = '';
        }

        CommonService.execute($scope.formAction, $scope.updateAction).then(function success(data) {
          $scope.isSubmitDisabled = false;
          if (data.error) {
            $scope.showModal('There was an error while saving this Powur Move.' + '<br>' + data.error.message);
            return;
          }
          $location.path('/admin/powur-move');
          $scope.showModal('You\'ve successfully saved this Powur Move.');
        });
      }
    };

    $scope.delete = function(leadActionObj) {
      var deleteAction = getAction(leadActionObj.actions, 'delete');
      if (window.confirm('Are you sure you want to delete this Powur Move?')) {
        return CommonService.execute(deleteAction).then(function() {
          $scope.showModal('This Powur Move has been deleted.');
          $location.path('/admin/powur-move');
        }, function() {
          $scope.showModal('There was an error deleting this Powur Move.');
        });
      }
    };

    this.init($scope, $location);
    this.fetch($scope, $rootScope, $location, $routeParams, CommonService);
  }

  // Utility Functions
  function getAction(actions, name) {
    for (var i in actions) {
      if (actions[i].name === name) {
        return actions[i];
      }
    }
    return;
  }

  AdminActionsCtrl.prototype.init = function($scope, $location) {

    // Setting mode based on the url
    $scope.mode = 'show';
    if (/\/powur-move$/.test($location.path())) return $scope.mode = 'index';
    if (/\/new$/.test($location.path())) return $scope.mode = 'new';
    if (/\/edit$/.test($location.path())) return $scope.mode = 'edit';
  };

  AdminActionsCtrl.prototype.fetch = function($scope, $rootScope, $location, $routeParams, CommonService) {
    if ($scope.mode === 'index') {
      $rootScope.breadcrumbs.push({title: 'Powur-Move Actions'});

      CommonService.execute({
        href: '/a/lead_actions.json'
      }).then(function(data) {
        $scope.leadActions = data;
        $scope.formAction = getAction(data.actions, 'update');
      });
    } else if ($scope.mode === 'new') {
      $rootScope.breadcrumbs.push({title: 'Powur-Move Actions', href: '/admin/powur-move'});
      $rootScope.breadcrumbs.push({title: 'New Powur-Move Action'});

      CommonService.execute({
        href: '/a/lead_actions'
      }).then(function(data) {
        $scope.formAction = getAction(data.actions, 'create');
        $scope.updateAction = { stage: 'pre' };
      });
    } else if ($scope.mode === 'edit') {
      $rootScope.breadcrumbs.push({title: 'Powur-Move Actions', href: '/admin/powur-move'});
      $rootScope.breadcrumbs.push({title: 'Edit Actions'});

      CommonService.execute({
        href: '/a/lead_actions/'  + $routeParams.actionId + '.json'
      }).then(function(data) {
        $scope.formAction = getAction(data.actions, 'update');
        $scope.leadActions = data;
        $scope.updateAction = data.properties;
      });
    }
  };

  AdminActionsCtrl.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$anchorScroll', '$http', 'CommonService'];
  angular.module('powurApp').controller('AdminActionsCtrl', AdminActionsCtrl);

})();
