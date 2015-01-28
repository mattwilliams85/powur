'use strict';

function UniversityCtrl($scope, $location, $window, $anchorScroll, UniversityClass) {
  $scope.redirectUnlessSignedIn();

  $scope.canTakeClass = function(universityClass) {
    var enrollable = universityClass.properties.enrollable;
    return enrollable && (universityClass.properties.purchased || universityClass.properties.price === 0);
  };

  $scope.canPurchaseClass = function(universityClass) {
    return(universityClass.properties.enrollable &&
           universityClass.properties.price > 0 &&
           !universityClass.properties.purchased);
  };

  $scope.takeClassClick = function(classItem) {
    $anchorScroll();
    $('<div class=\'reveal-modal\' data-reveal><h3>Enrolling ...</h3><a class=\'close-reveal-modal\'>&#215;</a></div>').foundation('reveal', 'open');
    $(document).foundation();

    var action;
    for (var i in classItem.actions) {
      if (classItem.actions[i].name === 'enroll') {
        action = classItem.actions[i];
      }
    }
    return UniversityClass.enroll(action).then(function(data) {
      $window.location.href = data.redirect_to;
    }, function() {
      $('body').trigger('click'); // close old modal
      $('<div class=\'reveal-modal\' data-reveal><h3>Oops error, we can\'t enroll you at the moment</h3><a class=\'close-reveal-modal\'>&#215;</a></div>').foundation('reveal', 'open');
    });
  };

  this.init($scope, $location);
  this.fetch($scope, UniversityClass);
}


UniversityCtrl.prototype.init = function($scope, $location) {
  // Setting mode based on the url
  $scope.mode = 'index';
  if (/\/[\d]+$/.test($location.path())) $scope.mode = 'else';
};


UniversityCtrl.prototype.fetch = function($scope, UniversityClass) {
  if ($scope.mode === 'index') {
    return UniversityClass.list().then(function(items) {
      $scope.universityClasses = items;
    });
  }
};


UniversityCtrl.$inject = ['$scope', '$location', '$window', '$anchorScroll', 'UniversityClass'];
sunstandControllers.controller('UniversityCtrl', UniversityCtrl);
