;(function() {
  'use strict';

  function AdminTwilioPhoneNumbersCtrl($scope, $rootScope, $http) {
    $scope.redirectUnlessSignedIn();

    $scope.templateData = {
      index: {
        title: 'Twilio Phone Numbers',
        tablePath: 'admin/twilio-phone-numbers/templates/table.html'
      }
    };

    $rootScope.breadcrumbs.push({title: 'Notifications'});
    $scope.index = {
      data: {entities: [{properties: {phone_number: 'Loading ...'}}]}
    };

    $http({
      method: 'GET',
      url: '/a/twilio_phone_numbers'
    }).success(function(data) {
      $scope.index.data = data;
    });
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

  AdminTwilioPhoneNumbersCtrl.$inject = ['$scope', '$rootScope', '$http'];
  angular.module('powurApp').controller('AdminTwilioPhoneNumbersCtrl', AdminTwilioPhoneNumbersCtrl);
})();
