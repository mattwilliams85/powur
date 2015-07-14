;(function() {
  'use strict';

  function LatestTermsCtrl($scope, $rootScope, $timeout, $location, UserProfile, CommonService) {
    $scope.redirectUnlessSignedIn();

    $scope.legacyImagePaths = legacyImagePaths;

    $scope.termsHeader = 'Application and Agreement'
    $scope.termsMessage1 = 'Powur has updated the Advocate Agreement.';
    $scope.termsMessage2 = 'Please review the agreement and click "Agree & Continue" to continue to the Dashboard.';

    //Fetch Profile
    UserProfile.get().then(function(data) {
      if (!data.properties.latest_terms){
        $location.path('/dashboard');
      } else {
        $scope.currentUser = data.properties;
        $scope.termsMessage = data.properties.latest_terms.message;
        $timeout(function() {
          new PDFObject({
            url: data.properties.latest_terms.document_path,
            height: '400px'
          }).embed('pdf-div');
        });
      }
    });

    $scope.acceptTerms = function() {
      UserProfile.update({user: {tos: $scope.currentUser.latest_terms.version}}).then(function(data) {
        $rootScope.currentUser.latest_terms = null;
        $scope.currentUser.latest_terms = null;
        $timeout(function() {
          $location.path('/dashboard');
        });
      });
    }

  }

  LatestTermsCtrl.$inject = ['$scope', '$rootScope', '$timeout', '$location', 'UserProfile', 'CommonService'];
  angular.module('powurApp').controller('LatestTermsCtrl', LatestTermsCtrl);
})();
