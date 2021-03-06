;(function() {
  'use strict';

  function AdminUserGroupRequirementsCtrl($scope, $rootScope, $location, $routeParams, $anchorScroll, $http, AdminUserGroup) {
    $scope.redirectUnlessSignedIn();
    $scope.view = 'requirements';
    $scope.requirement = {};
    $scope.formErrorMessages = {};

    // TODO check if user is an admin

    // Utility Functions
    $scope.getAction = function (actions, name) {
      for (var i in actions) {
        if (actions[i].name === name) {
          return actions[i];
        }
      }
      return;
    };

    $scope.getRequirementById = function (userGroup, requirementId) {
      for (var i in userGroup.entities[1].entities) {
        if (userGroup.entities[1].entities[i].properties.id === parseInt(requirementId)) {
          return (userGroup.entities[1].entities[i]);
        }
      }
      return;
    };

    $scope.cancel = function() {
      $location.path('/user-groups/'+ $scope.userGroup.id + '/requirements');
    };

    // Create Requirement Action
    $scope.create = function() {
      if ($scope.requirement) {
        $scope.isSubmitDisabled = true;
        AdminUserGroup.execute($scope.formAction, $scope.requirement).then(actionCallback($scope.formAction));
      }
    };

    // Update Requirement Action
    $scope.update = function() {
      if ($scope.requirement) {
        AdminUserGroup.execute($scope.formAction, $scope.requirement).then(actionCallback($scope.formAction));
      }
    };

    // Generic Requirement execute() Function & Related Callback
    $scope.execute = function (action, requirement) {
      if (action.name === 'update') {
        $scope.requirement = requirement;
        $location.path('/user-groups/' + $scope.userGroup.id + '/requirements/' + requirement.properties.id + '/edit');
      } else if (action.name === 'delete') {
        if (window.confirm("Are you sure you want to delete this requirement?")) {
          AdminUserGroup.execute(action, requirement).then(actionCallback(action));
        }
      } else {
        AdminUserGroup.execute(action, requirement).then(actionCallback(action));
      }
    };

    var actionCallback = function(action) {
      var destination = '/user-groups/' + $scope.userGroup.id + '/requirements',
          modalMessage = '';
      if (action.name === 'create') {
        destination = ('/user-groups/' + $scope.userGroup.id + '/requirements');
        modalMessage = ('You\'ve successfully added a new requirement.');
        $scope.isSubmitDisabled = false;
      } else if (action.name === 'update') {
        destination = ('/user-groups/' + $scope.userGroup.id + '/requirements');
        modalMessage = ('You\'ve successfully updated this requirement.');
      } else if (action.name === 'delete') {
        destination = ('/user-groups/' + $scope.userGroup.id + '/requirements');
        modalMessage = ('You\'ve successfully deleted this requirement.');
      }
      return AdminUserGroup.get($routeParams.userGroupId).then(function(item) {
        $location.path(destination);
        $scope.requirements = item.entities[1].entities;
        $scope.showModal(modalMessage);
      });
    };

    this.init($scope, $location);
    this.fetch($scope, $rootScope, $location, $routeParams, AdminUserGroup);
  }

  AdminUserGroupRequirementsCtrl.prototype.init = function($scope, $location) {
    $scope.mode = 'index';
    if (/\/requirements$/.test($location.path())) return $scope.mode = 'index';
    if (/\/new$/.test($location.path())) return $scope.mode = 'new';
    if (/\/edit$/.test($location.path())) return $scope.mode = 'edit';
  };

  AdminUserGroupRequirementsCtrl.prototype.fetch = function($scope, $rootScope, $location, $routeParams, AdminUserGroup) {
    if ($scope.mode === 'index') {
      AdminUserGroup.get($routeParams.userGroupId).then(function(item) {
        $scope.userGroup = item.properties;
        $scope.requirements = item.entities[1].entities;

        // Breadcrumbs: User Groups / User Group Name / Requirements
        $rootScope.breadcrumbs.push({title: 'User Groups', href: '/admin/user-groups'});
        $rootScope.breadcrumbs.push({title: $scope.userGroup.title, href: '/admin/user-groups/' + $scope.userGroup.id});
        $rootScope.breadcrumbs.push({title: 'Requirements'});

      });

    } else if ($scope.mode === 'new') {
      AdminUserGroup.get($routeParams.userGroupId).then(function(item) {
        $scope.userGroup = item.properties;
        $scope.requirement = {};
        $scope.formAction = $scope.getAction(item.entities[1].actions, 'create');

        // Breadcrumbs: User Groups / User Group Name / Requirements / New Requirement
        $rootScope.breadcrumbs.push({title: 'User Groups', href: '/admin/user-groups'});
        $rootScope.breadcrumbs.push({title: $scope.userGroup.title, href: '/admin/user-groups/' + $scope.userGroup.id});
        $rootScope.breadcrumbs.push({title: 'Requirements', href: '/admin/user-groups/' + $scope.userGroup.id + '/requirements'});
        $rootScope.breadcrumbs.push({title: 'New Requirement'});

      });

    } else if ($scope.mode === 'edit') {
      AdminUserGroup.get($routeParams.userGroupId).then(function(item) {
        $scope.userGroup = item.properties;
        $scope.requirementObj = $scope.getRequirementById(item, $routeParams.requirementId);
        $scope.formAction = $scope.getAction($scope.requirementObj.actions, 'update');

        var fields = $scope.formAction.fields;
        // Holy Loop to fill form with existing values 🙌
        for (var i in fields) {
          $scope.requirement[fields[i].name] = fields[i].value;
        }

        // Breadcrumbs: User Groups / User Group Name / Requirements / Update Requirement
        $rootScope.breadcrumbs.push({title: 'User Groups', href: '/admin/user-groups'});
        $rootScope.breadcrumbs.push({title: $scope.userGroup.title, href: '/admin/user-groups/' + $scope.userGroup.id});
        $rootScope.breadcrumbs.push({title: 'Requirements', href: '/admin/user-groups/' + $scope.userGroup.id + '/requirements'});
        $rootScope.breadcrumbs.push({title: 'Update Requirement'});

      });
    }
  };


  AdminUserGroupRequirementsCtrl.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$anchorScroll', '$http', 'AdminUserGroup'];
  angular.module('powurApp').controller('AdminUserGroupRequirementsCtrl', AdminUserGroupRequirementsCtrl);

})();
