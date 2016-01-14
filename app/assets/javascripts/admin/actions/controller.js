;(function() {
  'use strict';

  function AdminActionsCtrl($scope, $rootScope, $location, $routeParams, $anchorScroll, $http, CommonService) {
    $scope.redirectUnlessSignedIn();

    $scope.templateData = {
      index: {
        title: 'Powur-Move Actions',
        tablePath: 'admin/actions/templates/table.html'
      },
      edit: {
        title: 'Edit Powur-Move Action',
        formPath: 'admin/actions/templates/form.html'
      }
    };

    $scope.cancel = function() {
      $location.path('/admin/powur-move');
    };

    $scope.update = function() {
      if ($scope.updateAction) {
        CommonService.execute($scope.formAction, $scope.updateAction).then(function success(data) {
          $scope.isSubmitDisabled = true;
          if (data.error) {
            $scope.showModal('There was an error while updating this action.' + '<br>' + data.error.message);
            return;
          }
          $location.path('/admin/powur-move');
          $scope.showModal('You\'ve successfully updated this social media post.');
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
    if (/\/edit$/.test($location.path())) return $scope.mode = 'edit';
  };

  AdminActionsCtrl.prototype.fetch = function($scope, $rootScope, $location, $routeParams, CommonService) {
    if ($scope.mode === 'index') {
      $rootScope.breadcrumbs.push({title: 'Powur-Move Actions'});
      CommonService.execute({
        href: '/a/lead_actions.json'
      }).then(function(data) {
        $scope.lead_actions = data;
        $scope.formAction = getAction(data.actions, 'update');
      });

    } else if ($scope.mode === 'edit') {
      $rootScope.breadcrumbs.push({title: 'Powur-Move Actions', href: '/admin/powur-move'});
      $rootScope.breadcrumbs.push({title: 'Edit Actions'});
      CommonService.execute({
        href: '/a/lead_actions/'  + $routeParams.actionId + '.json'
      }).then(function(data) {
        $scope.formAction = getAction(data.actions, 'update');
        $scope.updateAction = data.properties;
      });
      // Breadcrumbs: Social Media Sharing / Edit Social Media Post
      // $rootScope.breadcrumbs.push({title: 'Social Media Sharing', href: '/admin/social-media'});

    }
  };

  AdminActionsCtrl.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$anchorScroll', '$http', 'CommonService'];
  angular.module('powurApp').controller('AdminActionsCtrl', AdminActionsCtrl);

})();
