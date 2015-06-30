;(function() {
  'use strict';

  function AdminUsersCtrl($scope, $rootScope, $location, $routeParams, $anchorScroll, $http, CommonService) {
    $scope.redirectUnlessSignedIn();

    $scope.templateData = {
      index: {
        title: 'Users',
        tablePath: 'admin/users/templates/table.html'
      }
    };

    $scope.pagination = function(direction) {
      var page = 1;
      if ($scope.indexData) {
        page = $scope.indexData.properties.paging.current_page;
      }
      page += direction;
      return CommonService.execute({
        href: '/a/users.json?page=' + page
      }).then(function(data) {
        $scope.indexData = data;
        $anchorScroll();
      });
    };

    $scope.cancel = function() {
      $location.path('/admin/users');
    };

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

    $scope.getEntityData = function(entities, entityRel) {
      var entity;
      for (var i = 0; i < entities.length; i++) {
        entities[i].rel[0] === entityRel ? (entity = entities[i]) : false;
      }
      if (entity) {
        CommonService.execute({
          href: entity.href
        }).then(function(item) {
          $scope[entityRel] = item;
          return $scope[entityRel];
        });
      }

    };

    // Update Action
    $scope.update = function() {
      if ($scope.formValues) {
        CommonService.execute({
          href: '/a/users/' + $routeParams.userId + '.json',
          method: 'PATCH',
        }, $scope.formValues).then(function success(data) {
          $scope.isSubmitDisabled = true;
          if (data.error) {
            $scope.showModal('There was an error while updating this user.');
            return;
          }
          $anchorScroll();
          $location.path('/admin/users/' + $routeParams.userId);
          $scope.isSubmitDisabled = false;
          $scope.showModal('You\'ve successfully updated this user!');
        });
      }
    };

    // Search Action
    $scope.search = function() {
      var data = {};
      if ($scope.usersSearch) {
        data.search = $scope.usersSearch;
      }
      if ($scope.usersSearch !== '') {
        $scope.searching = true;
      } else if ($scope.usersSearch === '') {
        $scope.searching = false;
      }

      $http({
        method: 'GET',
        url: '/a/users.json',
        params: data,
      }).success(function(data) {
        $scope.indexData = data;
        $anchorScroll;
      });
    };

    // Invites Actions
    // Execute Invite Action

    $scope.executeInviteAction = function(action) {
      if (confirm('Are you sure you want to ' + action.name + ' this invite?')) {
        CommonService.execute({
          href: action.href,
          method: action.method
        }).then(function(item) {
          if (action.name === 'resend') {
            $scope.showModal('This invite has been resent successfully.');
          } else if (action.name === 'delete') {
            $scope.showModal('This invite has been deleted successfully.');
          }
          $scope.user_invites = item;
          $scope.user_invites.properties.available_invites = item.properties.available_invites;
        })
      }
    }
    // Update Available Invites Action
    $scope.updateAvailableInvites = function(item) {
      var data = {invites: item.properties.available_invites};
      CommonService.execute({
        href: '/a/users/' + item.properties.id + '/invites.json',
        method: 'PATCH',
      }, data).then(function success(data) {
        if (data.error) {
          $scope.showModal('There was an error while updating this user.');
          return;
        }
        $scope.showModal('You\'ve successfully updated this user\'s available invites count!');
        $anchorScroll;
      });
    };

    this.init($scope, $location);
    this.fetch($scope, $rootScope, $location, $routeParams, CommonService);
  }

  AdminUsersCtrl.prototype.init = function($scope, $location) {
    // Setting mode based on the url
    $scope.mode = 'show';
    if (/\/users$/.test($location.path())) return $scope.mode = 'index';
    if (/\/new$/.test($location.path())) return $scope.mode = 'new';
    if (/\/edit$/.test($location.path())) return $scope.mode = 'edit';
  };

  AdminUsersCtrl.prototype.fetch = function($scope, $rootScope, $location, $routeParams, CommonService) {
    if ($scope.mode === 'index') {
      // Breadcrumbs: Users
      $rootScope.breadcrumbs.push({title: 'Users'});
      $scope.pagination(0);

    } else if ($scope.mode === 'show') {
      CommonService.execute({
        href: '/a/users/' + $routeParams.userId + '.json'
      }).then(function(item) {
        $scope.user = item;
        $scope.formAction = $scope.getAction(item.actions, 'update');
        $scope.formValues = $scope.setFormValues($scope.formAction);

        // Get Data for Invites
        $scope.getEntityData(item.entities, 'user_invites');

        // Breadcrumbs: Users / User Name
        $rootScope.breadcrumbs.push({title: 'Users', href: '/admin/users'});
        $rootScope.breadcrumbs.push({title: $scope.user.properties.first_name + ' ' + $scope.user.properties.last_name});

      });

    } else if ($scope.mode === 'edit') {
      CommonService.execute({
        href: '/a/users/' + $routeParams.userId +'.json'
      }).then(function(item) {
        $scope.user = item;
        $scope.formAction = $scope.getAction(item.actions, 'update');
        $scope.formValues = $scope.setFormValues($scope.formAction);

        // Breadcrumbs: Users / Edit User
        $rootScope.breadcrumbs.push({title: 'Users', href: '/admin/users'});
        $rootScope.breadcrumbs.push({title: ($scope.user.properties.first_name + ' ' + $scope.user.properties.last_name), href: '/admin/users/' + $scope.user.properties.id});
        $rootScope.breadcrumbs.push({title: 'Edit User'});
      });
    }
  };

  AdminUsersCtrl.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$anchorScroll', '$http', 'CommonService'];
  angular.module('powurApp').controller('AdminUsersCtrl', AdminUsersCtrl);

})();
