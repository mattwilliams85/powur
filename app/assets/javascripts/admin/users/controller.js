;(function() {
  'use strict';

  function AdminUsersCtrl($scope, $rootScope, $location, $routeParams, $anchorScroll, $http, AdminUser) {
    $scope.redirectUnlessSignedIn();

    // Utility Functions
    $scope.getAction = function(actions, name) {
      for (var i in actions) {
        if (actions[i].name === name) {
          return actions[i];
        }
      }
      return;
    };

    $scope.setFormValues = function(formAction) {
      var formValues = {};
      for (var i in formAction.fields) {
        var key = formAction.fields[i].name;
        var value = formAction.fields[i].value;
        formValues[key] = (value);
      }
      return formValues;
    };

    $scope.cancel = function() {
      $location.path('/users/' + $scope.user.properties.id);
    };

    // Update Action
    $scope.update = function() {
      if ($scope.formValues) {
        AdminUser.execute($scope.formAction, $scope.formValues).then(actionCallback($scope.formAction));
      }
    };

    var actionCallback = function(action) {
      var destination = '/users/' + $scope.user.properties.id,
          modalMessage = '';
      if (action.name === 'update') {
        destination = ('/users/' + $scope.user.properties.id);
        modalMessage = ('You\'ve successfully updated this user.');
      }
      return AdminUser.get($routeParams.userId).then(function(item) {
        $location.path(destination);
        $scope.user = item;
        $scope.showModal(modalMessage);
      });
    };

    // Search for Users
    $scope.search = function() {
      if ($scope.userSearch) {
        AdminUser.search($scope.searchAction, $scope.userSearch).then(function(items) {
          $scope.users = items.entities;
        });
      }
    };

    this.init($scope, $location);
    this.fetch($scope, $rootScope, $location, $routeParams, AdminUser);
  }

  AdminUsersCtrl.prototype.init = function($scope, $location) {
    // Setting mode based on the url
    $scope.mode = 'show';
    if (/\/users$/.test($location.path())) return $scope.mode = 'index';
    if (/\/new$/.test($location.path())) return $scope.mode = 'new';
    if (/\/edit$/.test($location.path())) return $scope.mode = 'edit';
  };

  AdminUsersCtrl.prototype.fetch = function($scope, $rootScope, $location, $routeParams, AdminUser) {
    if ($scope.mode === 'index') {
      AdminUser.list().then(function(items) {
        $scope.users = items.entities;
        $scope.searchAction = $scope.getAction(items.actions, 'index');
        $scope.userSearch = {};
        // Breadcrumbs: Users
        $rootScope.breadcrumbs.push({title: 'Users'});

      });

    } else if ($scope.mode === 'new') {

    } else if ($scope.mode === 'show') {
      AdminUser.get($routeParams.userId).then(function(item) {
        $scope.user = item;

        // Build Genealogy Tree
        $scope.tree = {}; // awaiting function to populate object with users grid
        $(function () { $('#jstree_demo_div').jstree($scope.tree); });

        // Breadcrumbs: Users / User Name
        $rootScope.breadcrumbs.push({title: 'Users', href: '/admin/users'});
        $rootScope.breadcrumbs.push({title: $scope.user.properties.first_name + ' ' + $scope.user.properties.last_name});

      });

    } else if ($scope.mode === 'edit') {
      $scope.formValues = {};
      AdminUser.get($routeParams.userId).then(function(item) {
        $scope.user = item;
        $scope.formAction = $scope.getAction(item.actions, 'update');
        $scope.formValues = $scope.setFormValues($scope.formAction);

        // Breadcrumbs: Users / Update User
        $rootScope.breadcrumbs.push({title: 'Users', href: '/admin/users'});
        $rootScope.breadcrumbs.push({title: ($scope.user.properties.first_name + ' ' + $scope.user.properties.last_name), href: '/admin/users/' + $scope.user.properties.id});
        $rootScope.breadcrumbs.push({title: 'Update User'});

      });
    }
  };

  AdminUsersCtrl.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$anchorScroll', '$http', 'AdminUser'];
  angular.module('powurApp').controller('AdminUsersCtrl', AdminUsersCtrl);

})();
