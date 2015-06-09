;(function() {
  'use strict';

  function DashboardCustomersCtrl($scope, $rootScope, $location, $http, $timeout, $route, $anchorScroll, CommonService) {
    $scope.redirectUnlessSignedIn();

    $scope.legacyImagePaths = legacyImagePaths;

    // Utility Functions:
    function getQuotes(cb) {
      CommonService.execute({
        href: '/u/users/' + $rootScope.currentUser.id + '/quotes.json'
      }).then(cb);
    }

    // Get an action with a given name
    $scope.getAction = function(actions, name) {
      for (var i in actions) {
        if (actions[i].name === name) {
          return actions[i];
        }
      }
      return;
    };

    // Check if action exists (used in front-end for action buttons)
    $scope.hasAction = function(actionName) {
      if ($scope.proposal) {
        var action = $scope.getAction($scope.proposalItem.actions, actionName);
        if (action) return true;
        else return false;
      }
      return;
    };

    // Set values from action's fields' values
    $scope.setFormValues = function(formAction) {
      var formValues = {};
      for (var i in formAction.fields) {
        var key = formAction.fields[i].name;
        var value = formAction.fields[i].value;
        formValues[key] = (value) || '';
      }
      return formValues;
    };

    // Determine which fields from action's fields are dynamic "product fields"
    $scope.setProductFields = function(formAction) {
      var productFields = [];
      for (var i in formAction.fields) {
        if (formAction.fields[i].product_field) {
          productFields.push(formAction.fields[i]);
        }
      }
      return productFields;
    };

    // Initialize Carousel
    var initCarousel = function(carouselElement) {
      $(carouselElement).owlCarousel({
        items: 4,
        itemsCustom: false,
        itemsDesktop: [1199,4],
        itemsDesktopSmall : [1024,3],
        itemsTablet: [768,2],
        itemsTabletSmall: false,
        itemsMobile: [640,1],
        navigation: true,
        navigationText: false,
        rewindNav: true,
        rewindSpeed: 200,
        scrollPerPage: true,
        slideSpeed: 500,
        mouseDrag: false,
        touchDrag: true,
        beforeMove: closeForm
      });

    };

    // Close Form when Moving Carousel
    var closeForm = function(event) {
      if ($scope.updatingProposal !== true) {
        $timeout(function() {
          $scope.closeForm();
        });
      }
    };

    // Destroy Carousel
    var destroyCarousel = function(carouselElement) {
      $(carouselElement).data('owlCarousel').destroy();
    };

    // Refresh Carousel
    function refreshCarousel(cb) {
      getQuotes(function(items) {
        $scope.closeForm();
        destroyCarousel('.proposals');
        $timeout(function() {
          $scope.proposals = items.entities;
          $timeout(function() {
            initCarousel('.proposals');
            if (cb) return cb();
            return;
          });
        });
      });
    }

    // Controller Actions:

    // Show Proposal
    $scope.customerSection.showProposal = function(proposalIndex) {
      $scope.updatingProposal = false;
      var proposalId = $scope.proposals[proposalIndex].properties.id;
      $scope.proposalIndex = proposalIndex;
      if ($scope.showForm === true && (proposalId === $scope.currentProposal.id)) {
        $scope.closeForm();
        return;
      } else {
        $scope.showForm = false;
        $scope.drilldownActive = false;
        $scope.currentProposalIndex = proposalIndex;

        CommonService.execute({
          href: '/u/quotes/' + proposalId + '.json'
        }).then(function(item){
          $scope.animateDrilldown();
          if  (item.properties.status === 'submitted' ||
              item.properties.status === 'in_progress' ||
              item.properties.status === 'closed_won' ||
              item.properties.status === 'lost' ||
              item.properties.status === 'on_hold'){
            $timeout( function(){
              $scope.proposal = item.properties;
              $scope.proposalItem = item;
              $scope.showProductFields = !!Object.keys(item.properties.product_fields).length;
              $scope.currentProposal = item.properties;
              $scope.mode = item.properties.status;
            }, 300);
          } else {
            $timeout( function(){
              $scope.formAction = $scope.getAction(item.actions, 'update');
              $scope.proposalItem = item;
              $scope.proposal = $scope.setFormValues($scope.formAction);
              $scope.proposal.productFields = $scope.setProductFields($scope.formAction);
              $scope.currentProposal = item.properties;
              $scope.mode = item.properties.status;
            }, 300);
          }
        });
      }
    };

    // New Proposal Action
    $scope.customerSection.newProposal = function() {
      if ($scope.showForm === true && $scope.mode === 'new') {
        $scope.closeForm();
        return;
      } else {
        $scope.showForm = false;
        $scope.drilldownActive = false;
        $scope.animateDrilldown();
        $scope.proposal = {};
        $scope.currentProposal = {};

        getQuotes(function(items){
          $scope.animateDrilldown();

          $timeout( function(){
            $scope.mode = 'new';
            $scope.formAction = $scope.getAction(items.actions, 'create');
            $scope.proposal.productFields = $scope.setProductFields($scope.formAction);

          }, 200);
        });
      }
    };

    // Save/Update Proposal Action
    $scope.customerSection.saveProposal = function() {
      if ($scope.proposal && $('#customers-form')[0].checkValidity()) {
        CommonService.execute($scope.formAction, $scope.proposal).then(actionCallback($scope.formAction));
      }
    };

    function actionCallback(action) {
      return function() {
        if (action.name === 'create' || action.name === 'delete') {
          refreshCarousel(function() {
            $timeout(function() {
              if (action.name === 'create') {
                $('.proposals').data('owlCarousel').goTo(0);
                $scope.customerSection.showProposal(0);
              }
            });
          });

        } else if (action.name === 'update') {
          getQuotes(function(items) {
            $scope.updatingProposal = true;
            $scope.closeForm();
            destroyCarousel('.proposals');
            $scope.proposals = items.entities;
            $timeout(function() {
              initCarousel('.proposals');
              $timeout(function() {
                $('.proposals').data('owlCarousel').goTo($scope.proposalIndex);
                $scope.customerSection.showProposal($scope.proposalIndex);
              });
            });
          });
        } else if (action.name === 'submit') {
          console.log('submitted proposal!');
          $scope.closeForm();
          $anchorScroll();
          $scope.showModal('This proposal was submitted to SolarCity!');
          refreshCarousel();

        } else if (action.name === 'resend') {
          $scope.closeForm();
          $anchorScroll();
          $scope.showModal('This proposal email was successfully re-sent to ' +
            $scope.proposal.customer + ' at ' +
            $scope.proposal.email + '.');
        }
      };
    }

    // Submit Proposal to SolarCity Action
    $scope.customerSection.submit = function() {
      if (confirm('Please confirm that all fields in the customer\'s contact information are correct before proceeding. \n' +
          'Are you sure you want to submit this proposal to SolarCity?')) {
        $scope.submitAction = $scope.getAction($scope.proposalItem.actions, 'submit');
        if ($scope.submitAction) {
          CommonService.execute($scope.submitAction).then(actionCallback($scope.submitAction));
        } else {
          alert('This proposal can\'t be submitted to SolarCity.');
        }
      }
    };

    // Delete Proposal Action
    $scope.customerSection.delete = function() {
      if (confirm('Are you sure you want to delete this proposal?')) {
        var deleteAction = $scope.getAction($scope.proposalItem.actions, 'delete');
        if (deleteAction) {
          CommonService.execute(deleteAction).then(actionCallback(deleteAction));
        } else {
          alert("This proposal can't be deleted.");
        }
      }
    };

    // Resend Email Action
    $scope.customerSection.resend = function() {
      if (confirm('Are you sure you want to resend the proposal email to this customer?')) {
        var resendAction = $scope.getAction($scope.proposalItem.actions, 'resend');
        if (resendAction) {
          CommonService.execute(resendAction).then(actionCallback(resendAction));
        } else {
          alert("This proposal can't be re-sent.");
        }
      }
    };

    // Animate Form Opening/Closing
    $scope.animateDrilldown = function () {
      $scope.drilldownActive = true;
      $timeout( function(){
        $scope.showForm = true;
      }, 300);
    };

    // Close Form
    $scope.closeForm = function() {
      $scope.drilldownActive = false;
      $scope.showForm = false;
      $scope.currentProposal = {};
      $scope.mode = '';
    };

    // Index Actions

    // Defaults
    $scope.customerSection.proposalSort = 'created';
    $scope.customerSection.proposalStatus = '';
    $scope.customerSection.proposalSearch = '';

    // Apply Search
    $scope.customerSection.search = function () {
      $scope.customerSection.proposalSort = 'created';
      $scope.customerSection.proposalStatus = '';
      $scope.customerSection.applyIndexActions();
      if ($scope.customerSection.proposalSearch === '') {
        $scope.customerSection.searching = false;
      } else {
        $scope.customerSection.searching = true;
      }
    };

    // Apply Sort/Status
    $scope.customerSection.applyIndexActions = function() {
      var data = {
        sort: $scope.customerSection.proposalSort,
        status: $scope.customerSection.proposalStatus
      };
      if ($scope.customerSection.proposalSearch) {
        data.search = $scope.customerSection.proposalSearch;
      }
      var href = '/u/users/' + $rootScope.currentUser.id + '/quotes'
      destroyCarousel('.proposals');

      $http({
        method: 'GET',
        url: href,
        params: data,
      }).success(function(items) {
        $scope.proposals = items.entities;
        $timeout(function() {
          initCarousel('.proposals');
        });
      });
    };


    // getQuotes Main Function
    /*
    * The carousel needs $rootScope.currentUser.id when it calls the endpoint (/u/users/:userId/quotes.json)
    * This watches $rootScope.currentUser then calls getQuotes() when it has an object
    */
    $rootScope.$watch('currentUser', function(data) {
      if (!Object.keys(data).length) return;
      getQuotes(function(items) {
        $scope.proposals = items.entities;
        $timeout(function(){
          initCarousel('.proposals');
        });
      });
    });

  }

  DashboardCustomersCtrl.$inject = ['$scope', '$rootScope', '$location', '$http', '$timeout', '$route', '$anchorScroll', 'CommonService'];
  angular
    .module('powurApp')
    .controller('DashboardCustomersCtrl', DashboardCustomersCtrl);
})();
