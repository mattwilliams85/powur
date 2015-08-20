;(function() {
  'use strict';

  angular.module('powurApp')
    .controller('PayPeriodUsersCtrl', controller)
    // .config(routes);

  controller.$inject = ['$scope', '$rootScope', '$location', '$routeParams', '$anchorScroll', '$http'];
  function controller($scope, $rootScope, $location, $routeParams, $anchorScroll, $http) {
    $scope.redirectUnlessSignedIn();

    // $scope.templateData = {
    //   index: {
    //     title: 'Pay Periods',
    //     tablePath: 'admin/pay-periods/templates/table.html'
    //   },
    //   show: {
    //     title: 'Pay Period',
    //     tablePath: 'admin/pay-periods/templates/users.html'
    //   }
    // };


  }

})();
