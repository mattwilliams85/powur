;(function() {
  'use strict';

  function UniversityCtrl($scope, $rootScope, $location, $window, $anchorScroll, $routeParams, UniversityClass, UserProfile, Geo, CommonService) {
    $scope.redirectUnlessSignedIn();

    UserProfile.get().then(function(user) {
      $rootScope.currentUser = user;
    });

    function getAction(actions, name) {
      for (var i in actions) {
        if (actions[i].name === name) {
          return actions[i];
        }
      }
      return;
    }

    $scope.canTakeClass = function(universityClass) {
      var enrollable = universityClass.properties.enrollable && universityClass.properties.state !== 'completed';
      return enrollable && (universityClass.properties.purchased || universityClass.properties.price === 0);
    };

    $scope.canReviewClass = function(universityClass) {
      return universityClass.properties.enrollable && universityClass.properties.state === 'completed';
    };

    $scope.canPurchaseClass = function(universityClass) {
      return(universityClass.properties.enrollable &&
             universityClass.properties.price > 0 &&
             !universityClass.properties.purchased);
    };

    $scope.showCheckStatusButton = function(universityClass) {
      var state = universityClass.properties.state;
      return state === 'enrolled' ||
             state === 'started';
    };

    $scope.takeClass = function(classItem) {
      $anchorScroll();
      $scope.showModal('Enrolling ...', 'pow-modal');

      var action = getAction(classItem.actions, 'enroll');
      return CommonService.execute(action).then(function(data) {
        $window.location.href = data.redirect_to;
      }, function() {
        $('body').trigger('click'); // close old modal
        $scope.showModal('Oops error, we can\'t enroll you at the moment');
      });
    };

    $scope.reviewClass = function(classItem) {
      $anchorScroll();
      $scope.showModal('Redirecting ...', 'pow-modal');

      var action = getAction(classItem.actions, 'smarteru_signin');
      return CommonService.execute(action).then(function(data) {
        $window.location.href = data.redirect_to;
      }, function() {
        $('body').trigger('click'); // close old modal
        $scope.showModal('Oops error, we can\'t redirect you to smarteru at the moment');
      });
    };

    $scope.checkEnrollment = function(classItem) {
      $anchorScroll();
      $scope.showModal('Checking enrollment status ...', 'pow-modal');

      var action = getAction(classItem.actions, 'check_enrollment');
      return CommonService.execute(action).then(function(data) {
        classItem.properties = data.properties;
        $('.close-reveal-modal').trigger('click');
      });
    };

    $scope.purchase = function(classItem) {
      $scope.isPurchaseDisabled = true;
      $scope.errorMessage = null;
      var action = getAction(classItem.actions, 'purchase');
      return CommonService.execute(action, {card: $scope.card}).then(function(data) {
        $scope.isPurchaseDisabled = false;
        if (data.error) {
          for (var property in data.error.input) {
            return $scope.errorMessage = data.error.input[property][0];
          }
        } else {
          $scope.purchaseComplete = true;
        }
      });
    };

    return UniversityClass.list().then(function(items) {
      $scope.universityClasses = items;
    });
  }

  UniversityCtrl.$inject = ['$scope', '$rootScope', '$location', '$window', '$anchorScroll', '$routeParams', 'UniversityClass', 'UserProfile', 'Geo', 'CommonService'];
  angular.module('powurApp').controller('UniversityCtrl', UniversityCtrl);
})();
