;(function() {
  'use strict';

  function MembershipsCtrl($scope, $location, $anchorScroll, $window, $timeout, UserProfile, CommonService) {
    $scope.redirectUnlessSignedIn();

    UserProfile.get().then(function(data) {
      $scope.currentUser = data.properties;
    });

    $scope.legacyImagePaths = legacyImagePaths;
    $scope.memberships = {};
    $scope.selectedMembership = null;
    $scope.card = {};

    $scope.selectMembership = function(slug) {
      var membership = $scope.memberships[slug];
      $scope.selectedMembership = membership;

      $('.reveal-modal-purchase-membership').foundation('reveal', 'open');
    };

    $scope.membershipPrice = function(slug) {
      var membership = $scope.memberships[slug];
      if (membership) return membership.properties.price/100;
    };

    $scope.purchase = function(item) {
      $scope.isPurchaseDisabled = true;
      $scope.errorMessage = null;
      var action = getAction(item.actions, 'purchase');
      return CommonService.execute(action, {card: $scope.card}).then(function(data) {
        $scope.isPurchaseDisabled = false;
        if (data.error) {
          for (var property in data.error.input) {
            return $scope.errorMessage = data.error.input[property][0];
          }
        } else {
          item.properties.purchased = true;
          $scope.purchaseComplete = true;
        }
      }, function error() {
        $scope.isPurchaseDisabled = false;
        return $scope.errorMessage = "Error, we couldn't process your request";
      });
    };

    $scope.takeAClass = function() {
      if (!$scope.selectedMembership) return;

      var action = getAction($scope.selectedMembership.actions, 'enroll');

      function errorCallback(data) {
        var message = data.error.message || 'Oops error, we can\'t enroll you at the moment';

        closeModals();
        $timeout(function() {
          $location.path('/university');
          $scope.showModal(message);
        });
      }

      return CommonService.execute(action).then(function(data) {
        if (data.error) return errorCallback(data);

        $window.location.href = data.redirect_to;
      }, errorCallback);
    };

    $scope.scrollTo = function(domId) {
      var old = $location.hash();
      $location.hash(domId);
      $anchorScroll();
      $location.hash(old);
    };

    $scope.isPurchasable = function(slug) {
      return $scope.memberships[slug] && !$scope.memberships[slug].properties.purchased;
    };

    $scope.expChange = function() {
      $scope.card.expiration = $scope.card.expiration.replace(/\D/, '');
    };

    // More specific endpoint might be used later, the one that will only provide
    // purchasable membership products for current user
    return CommonService.execute({
      href: '/u/university_classes.json'
    }).then(function(items) {
      var item;
      for(var i in items.entities) {
        item = items.entities[i];
        if (item.properties.price > 0 && item.properties.slug) {
          $scope.memberships[item.properties.slug] = item;
        }
      }
    });

    /**
     * Utility functions
     */
    function getAction(actions, name) {
      for (var i in actions) {
        if (actions[i].name === name) {
          return actions[i];
        }
      }
      return;
    }

    function closeModals() {
      $('a.close-reveal-modal').trigger('click');
    }
  }

  MembershipsCtrl.$inject = ['$scope', '$location', '$anchorScroll', '$window', '$timeout', 'UserProfile', 'CommonService'];
  angular.module('powurApp').controller('MembershipsCtrl', MembershipsCtrl);
})();
