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
      if ($scope.proposalItem && Object.keys($scope.proposal).length) {
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
    function initCarousel(carouselElement) {
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
    }

    // Close Form when Moving Carousel
    function closeForm(event) {
      if ($scope.updatingProposal !== true) {
        $timeout(function() {
          $scope.closeForm();
        });
      }
    }

    // Destroy Carousel
    function destroyCarousel(carouselElement) {
      $(carouselElement).data('owlCarousel').destroy();
    }

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
              $scope.showNotes = !!item.properties.notes;
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
    $scope.customerSection.proposalSort = '';
    $scope.customerSection.proposalStatus = '';
    $scope.customerSection.proposalSearch = '';
    $scope.customerSection.indexAction = {};

    // Get Options from Index Action Fields for Sort and Status
    $scope.customerSection.getOptions = function(indexAction, fieldName) {
      for (var i in indexAction.fields) {
        if (indexAction.fields[i].name === fieldName) {
          return indexAction.fields[i].options;
        }
      }
    };

    // Set Options for Index Action Fields for Sort and Status
    /*
    * This function requires the initial getQuotes() request to run (see "getQuotes Main Function" below)
    * $scope.customerSection.indexAction is set within the getQuotes() callback
    */
    $scope.$watch('customerSection.indexAction', function(data) {
      if (!Object.keys(data).length) return;
      $scope.customerSection.proposalSortOptions = $scope.customerSection.getOptions($scope.customerSection.indexAction, 'sort');
      $scope.customerSection.proposalStatusOptions = $scope.customerSection.getOptions($scope.customerSection.indexAction, 'status');
    });

    // Apply Search
    $scope.customerSection.search = function (user) {
      if (!$scope.nameQuery.length) return;

      if(typeof(user) != 'object') {
        user = $scope.nameQuery[$scope.queryIndex];
        $scope.nameQuery = [];
      }
      for (var i=0; i < $scope.proposals.length; i++) {
        if($scope.proposals[i].properties.id === user.properties.id) {
          $('#customers-carousel').trigger('owl.jumpTo', i);
          $scope.customerSection.showProposal(i);
        }
      }
      // $scope.customerSection.proposalSort = '';
      // $scope.customerSection.proposalStatus = '';
      // $scope.customerSection.applyIndexActions();
      // if ($scope.customerSection.proposalSearch === '') {
      //   $scope.customerSection.searching = false;
      // } else {
      //   $scope.customerSection.searching = true;
      // }
    };

    $scope.customerSearch = {};
    $scope.nameQuery = []
    $scope.queryIndex = 0;

    $scope.key = function(key){
      if ((key === parseInt(key, 10))) return $scope.queryIndex = key;
      if (!$scope.nameQuery.length) return;

      if (key.keyCode == 38) {
        if ($scope.queryIndex < 1) return;
        $scope.queryIndex -= 1;
      } else if (key.keyCode == 40) {
        if( $scope.queryIndex + 1 === $scope.nameQuery.length) return;
        $scope.queryIndex += 1;
      }
    }

    $scope.clearQuery = function(i) {
      $scope.focused = true;
      $timeout(function() {
        if(i) $scope.focused = false;
        $scope.queryIndex = 0;
      }, 150)    
    }

    $scope.fetchNames = function(){
      if (!$scope.customerSearch.string) {
        $scope.queryIndex = 0;
        return $scope.nameQuery = [];
      }
      CommonService.execute({
        href: '/u/users/' + $rootScope.currentUser.id + '/quotes.json',
        params: {search: $scope.customerSearch.string, limit: 7}
      }).then(function(items){
        // debugger
        $scope.nameQuery = items.entities;
        $timeout(function() {
          $('.left-label').wrapInTag({
            tag: 'span class="highlight"',
            words: [$scope.customerSearch.string]
          });
        })
       
      });
    }

    // Apply Sort/Status
    $scope.customerSection.applyIndexActions = function() {
      var data = {
        sort: $scope.customerSection.proposalSort,
        status: $scope.customerSection.proposalStatus
      };
      if ($scope.customerSection.proposalSearch) {
        data.search = $scope.customerSection.proposalSearch;
      }
      if ($scope.customerSection.proposalStatus !== '') {
        $scope.customerSection.searching = true;
      }

      var href = '/u/users/' + $rootScope.currentUser.id + '/quotes'
      $scope.closeForm();
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
        // Set Proposals
        $scope.proposals = items.entities;
        // Set Index Action
        $scope.customerSection.indexAction = $scope.getAction(items.actions, 'index');
        // Initialize Proposals Carousel
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
