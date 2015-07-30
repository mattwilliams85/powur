;(function() {
  'use strict';

  function AdminUsersCtrl($scope, $rootScope, $location, $routeParams, $anchorScroll, $http, CommonService) {
    $scope.redirectUnlessSignedIn();

    $scope.legacyImagePaths = legacyImagePaths;

    // Sections
    $scope.invites = {};
    $scope.overview = {};

    $scope.templateData = {
      index: {
        title: 'Users',
        tablePath: 'admin/users/templates/table.html'
      },
      move: {
        title: 'Move User',
        tablePath: 'admin/users/templates/move-table.html'
      }
    };

    $scope.pagination = function(direction) {
      var page = 1,
          sort;
      if ($scope.index.data) {
        page = $scope.index.data.properties.paging.current_page;
        sort = $scope.index.data.properties.sorting.current_sort;
      }
      page += direction;
      return CommonService.execute({
        href: '/a/users',
        params: {
          page: page,
          sort: sort
        }
      }).then(function(data) {
        $scope.index.data = data;
        $anchorScroll();
      });
    };

    $scope.cancel = function() {
      $location.path('/admin/users');
    };

    $scope.confirm = function(msg, clickAction, arg) {
      if (window.confirm(msg)) {
        return $scope.$eval(clickAction)(arg);
      }
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

    //
    // User Actions
    //

    // Update
    $scope.update = function() {
      if ($scope.formValues) {
        $scope.isSubmitDisabled = true;
        CommonService.execute({
          href: '/a/users/' + $routeParams.userId + '.json',
          method: 'PATCH',
        }, $scope.formValues).then(function success(data) {
          if (data.error) {
            $scope.showModal('There was an error while updating this user.');
            $scope.isSubmitDisabled = false;
            return;
          }
          $anchorScroll();
          $location.path('/admin/users/' + $routeParams.userId);
          $scope.isSubmitDisabled = false;
          $scope.showModal('You\'ve successfully updated this user!');
        });
      }
    };

    // Search
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
        url: '/a/users',
        params: data,
      }).success(function(data) {
        $scope.index.data = data;
        $anchorScroll();
      });
    };

    $scope.searchParent = function() {
      var action = getAction($scope.actions, 'eligible_parents');

      $http({
        method: action.method,
        url: action.href,
        params: { search: $scope.usersSearch },
      }).success(function(data) {
        $scope.index.data = data;
      });
    };

    $scope.setNewParent = function(newParent) {
      var action = getAction($scope.actions, 'move');

      $http({
        method: action.method,
        url: action.href,
        params: { parent_id: newParent.properties.id },
      }).success(function() {
        $location.path('/admin/users/' + $scope.user.properties.id);
        $scope.showModal('You\'ve successfully moved user to a new team!');
      });
    };

    //
    // Invite Actions
    //

    // Execute Invite Action
    $scope.invites.executeInviteAction = function(action) {
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
        });
      }
    };

    // Update Available Invites Action
    $scope.invites.updateAvailableInvites = function(item) {
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
        $anchorScroll();
      });
    };

    //
    // Overview Actions
    //

    // Get Sponsor/Coach for User
    $scope.overview.getSponsors = function(userItem) {
      $http({
        method: 'GET',
        url: '/a/users/' + userItem.properties.id + '/sponsors.json',
      }).success(function(res) {
        $scope.overview.teamLeader = res.entities[0];
        $scope.overview.coach = res.entities[1];
      }).error(function(err) {
        console.log('エラー', err);
      });
    };

    // Give Complimentary Course
    $scope.overview.giveComplimentaryCourse = function() {
      var confirmMessage = 'This will give ' + $scope.fullName($scope.user) + ' free access to this course in Powur U. Are you sure?';

      // Get Product Receipt Create Action
      $scope.giveComplimentaryCourseAction = getAction($scope.user_product_receipts.actions, 'create');

      if ($scope.overview.complimentaryCourse && confirm(confirmMessage)) {
        CommonService.execute($scope.giveComplimentaryCourseAction, $scope.overview.complimentaryCourse).then(function(data){
          $scope.getEntityData($scope.user.entities, 'user_product_receipts');
        });
      }
    };

    $scope.fullName = function(user) {
      return user.properties.first_name + ' ' + user.properties.last_name;
    }

    this.init($scope, $location);
    this.fetch($scope, $rootScope, $location, $routeParams, CommonService);
  }

  AdminUsersCtrl.prototype.init = function($scope, $location) {
    // Setting mode based on the url
    $scope.mode = 'show';
    if (/\/users$/.test($location.path())) return $scope.mode = 'index';
    if (/\/new$/.test($location.path())) return $scope.mode = 'new';
    if (/\/edit$/.test($location.path())) return $scope.mode = 'edit';
    if (/\/edit_password$/.test($location.path())) return $scope.mode = 'edit_password';
    if (/\/move$/.test($location.path())) return $scope.mode = 'move';
  };

  AdminUsersCtrl.prototype.fetch = function($scope, $rootScope, $location, $routeParams, CommonService) {
    if ($scope.mode === 'index') {
      // Breadcrumbs: Users
      $rootScope.breadcrumbs.push({title: 'Users'});
      $scope.index = {};
      $scope.pagination(0);
    } else if ($scope.mode === 'show') {
      getUser($routeParams.userId, function(item) {
        $scope.user = item;
        $scope.formAction = getAction(item.actions, 'update');
        $scope.formValues = setFormValues($scope.formAction);

        // Get Data for Sponsors
        $scope.overview.getSponsors(item);

        // Get Data for Invites
        $scope.getEntityData(item.entities, 'user_invites');

        // Get Data for Product Enrollments
        $scope.getEntityData(item.entities, 'user_product_enrollments');

        // Get Data for Product Receipts
        $scope.getEntityData(item.entities, 'user_product_receipts');

        // Breadcrumbs: Users / User Name
        $rootScope.breadcrumbs.push({title: 'Users', href: '/admin/users'});
        $rootScope.breadcrumbs.push({title: $scope.fullName($scope.user)});
      });
    } else if ($scope.mode === 'edit') {
      getUser($routeParams.userId, function(item) {
        $scope.user = item;
        $scope.formAction = getAction(item.actions, 'update');
        $scope.formValues = setFormValues($scope.formAction);

        // Breadcrumbs: Users / Edit User
        $rootScope.breadcrumbs.push({title: 'Users', href: '/admin/users'});
        $rootScope.breadcrumbs.push({title: $scope.fullName($scope.user), href: '/admin/users/' + $scope.user.properties.id});
        $rootScope.breadcrumbs.push({title: 'Edit User'});
      });
    } else if ($scope.mode === 'move') {
      $scope.index = {};
      getUser($routeParams.userId, function(item) {
        $scope.user = item;
        $scope.actions = item.actions;

        $rootScope.breadcrumbs.push({title: 'Users', href: '/admin/users'});
        $rootScope.breadcrumbs.push({title: $scope.fullName($scope.user), href: '/admin/users/' + $scope.user.properties.id});
        $rootScope.breadcrumbs.push({title: 'Move User'});
      });
    } else if ($scope.mode === 'edit_password') {
      getUser($routeParams.userId, function(item) {
        $rootScope.breadcrumbs.push({title: 'Users', href: '/admin/users'});
        $rootScope.breadcrumbs.push({title: $scope.fullName($scope.user), href: '/admin/users/' + item.properties.id});
        $rootScope.breadcrumbs.push({title: 'Edit Password'});
      });
    }

    function getUser(userId, cb) {
      CommonService.execute({
        href: '/a/users/' + userId
      }).then(cb);
    }
  };

  //
  // Utility Functions
  //

  function getAction(actions, name) {
    for (var i in actions) {
      if (actions[i].name === name) {
        return actions[i];
      }
    }
  }

  function setFormValues(formAction) {
    var formValues = {};
    for (var i in formAction.fields) {
      var key = formAction.fields[i].name;
      var value = formAction.fields[i].value;
      formValues[key] = (value);
    }
    return formValues;
  }

  AdminUsersCtrl.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$anchorScroll', '$http', 'CommonService'];
  angular.module('powurApp').controller('AdminUsersCtrl', AdminUsersCtrl);

})();
