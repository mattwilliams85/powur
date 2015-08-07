;(function() {
  'use strict';

  angular.module('powurApp')
    .controller('AdminTwilioStatsCtrl', controller)
    .config(routes);

  controller.$inject = ['$scope', '$rootScope', '$http'];
  function controller($scope, $rootScope, $http) {
    $scope.redirectUnlessSignedIn();

    $scope.templateData = {
      index: {
        title: 'Twilio Stats',
        tablePath: 'admin/twilio-stats/templates/table.html'
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

  routes.$inject = ['$routeProvider'];
  function routes($routeProvider) {
    $routeProvider.
    when('/admin/twilio-stats', {
      templateUrl: 'shared/admin/rest/index.html',
      controller: 'AdminTwilioStatsCtrl'
    });
  }

})();
