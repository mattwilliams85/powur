;(function() {
  'use strict';

  function UniversityCtrl($scope, $location, $window, $anchorScroll, $routeParams, UniversityClass, UserProfile, Geo, CommonService) {
    $scope.redirectUnlessSignedIn();

    UserProfile.get().then(function(user) {
      $scope.currentUser = user;
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

    $scope.canPurchaseClass = function(universityClass) {
      return(universityClass.properties.enrollable &&
             universityClass.properties.price > 0 &&
             !universityClass.properties.purchased);
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

    $scope.purchase = function(classItem) {
      $scope.isPurchaseDisabled = true;
      $scope.errorMessage = null;
      var action = getAction(classItem.actions, 'purchase');
      return CommonService.execute(action, {card: $scope.card}).then(function() {
        $scope.purchaseComplete = true;
      }, function errorCallback(data) {
        $scope.isPurchaseDisabled = false;
        if (data.errors) {
          for (var property in data.errors) {
            return $scope.errorMessage = data.errors[property][0];
          }
        }
      });
    };

    this.init($scope, $location);
    this.fetch($scope, $routeParams, $location, UniversityClass, UserProfile, Geo);
  }


  UniversityCtrl.prototype.init = function($scope, $location) {
    // Setting mode based on the url
    $scope.mode = 'index';
    if (/\/purchase$/.test($location.path())) return $scope.mode = 'purchase';
  };


  UniversityCtrl.prototype.fetch = function($scope, $routeParams, $location, UniversityClass, UserProfile, Geo) {
    if ($scope.mode === 'index') {
      return UniversityClass.list().then(function(items) {
        $scope.universityClasses = items;
      });
    } else if ($scope.mode === 'purchase') {
      $scope.card = {};
      $scope.$watch('currentUser', function(data) {
        if (data && data.first_name) {
          $scope.card.email = data.email;
          $scope.card.address = data.address;
          $scope.card.zip = data.zip;
          $scope.card.city = data.city;
          $scope.card.state = data.state;
          $scope.card.phone = data.phone;
          $scope.card.name = data.first_name + ' ' + data.last_name;
          $scope.card.zip = data.zip;
        }
      });
      $scope.states = Geo.states();

      return UniversityClass.get($routeParams.classId).then(function(data) {
        $scope.classItem = data;
        if ($scope.classItem.properties.purchased || $scope.classItem.properties.price === 0) {
          $location.path('/university');
        }
      });
    }
  };

  UniversityCtrl.$inject = ['$scope', '$location', '$window', '$anchorScroll', '$routeParams', 'UniversityClass', 'UserProfile', 'Geo', 'CommonService'];
  angular.module('powurApp').controller('UniversityCtrl', UniversityCtrl);
})();
