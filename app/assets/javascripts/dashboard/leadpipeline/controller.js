;(function() {
  'use strict';

  function DashboardLeadPipelineCtrl($scope, $rootScope, $location, $http, $timeout, $route, $anchorScroll, CommonService) {
    $scope.redirectUnlessSignedIn();

    $scope.legacyImagePaths = legacyImagePaths;

    // Lead Status Definitions
    var leadStatusDefinitions = {
      incomplete: 'The lead you have saved is missing key information required by SolarCity to accept the lead.',
      ineligible_location: 'The zip code entered for this lead is outside the SolarCity service area.',
      ready_to_submit: 'Your lead is good to go.',
      submitted: 'The powur.com platform has submitted your lead.',
      qualified: 'This customer qualifies for solar. An opportunity or consultation has been scheduled with a SolarCity representative.',
      called_2x: 'A SolarCity representative called this customer 2 times without getting a hold of them.',
      called_3x: 'A SolarCity representative called this customer 3 times without getting a hold of them.',
      called_4x: 'A SolarCity representative called this customer 4 times without getting a hold of them.',
      no_contact_established: 'No contact was established with this customer after 5 days. (1 call per day)',
      contacted: 'The customer was reached by phone, but was unavailable.',
      existing_active_opportunity: 'The customer is already qualified and was submitted to the SolarCity system within the last 45 days.',
      existing_lead: 'The customer was already submitted to the SolarCity system within the last 45 days.',
      open: 'SolarCity hasn\'t assigned an advisor to reach out to this customer.',
      out_of_driving_range: 'The customer is located outside of the SolarCity service territory.',
      out_of_state: 'The customer\'s state is not serviced by SolarCity.',
      unqualified: 'The customer does not qualify for solar. (not a homeowner, excessive shading, etc.)',
      closed_won: 'The customer has signed a contract and has begun working with SolarCity\'s operations team.',
      contract_out: 'The customer passed the credit check and the SolarCity representative has sent a contract to the customer via DocuSign.',
      proposal_presented: 'The SolarCity representative has gone over the proposal and savings with the customer.',
      consultation_scheduled: 'The customer has scheduled a time to meet with the SolarCity sales representative to go over the proposal.',
      opportunity_identified: 'The customer is gathering their utility bills, usage, and other information before moving forward with SolarCity.',
      legacy_in_progress: 'The SolarCity sales representative could not get the qualified customer to sign up. The Legacy team will step in to try to close the deal.',
      closed_lost: 'The customer did not want to go solar.',
      unqualified: 'The customer did not qualify for solar.'
    }

    var leadStatusActions = {
      incomplete: 'Examine the lead information form, make sure alll fields are complete, and save again.',
      ineligible_location: 'Check the ZIP code and make sure you entered it correctly. All data is verified with the customer and your lead will be disqualified if it is outside of the service area.',
      ready_to_submit: 'Click the \'Submit to SolarCity\' button to submit your lead.',
      called_2x: 'Allow SolarCity to get a hold of the customer, but keep an eye on this lead.',
      called_3x: 'Get a hold of your lead and 3-way call (855) 477-7652 for an advisor. Make the connection, then drop off the line so the customer can share their information with the advisor.',
      called_4x: 'Get a hold of your lead and 3-way call (855) 477-7652 for an advisor. Make the connection, then drop off the line so the customer can share their information with the advisor.',
      no_contact_established: 'Get a hold of your lead and 3-way call (855) 477-7652 for an advisor. Make the connection, then drop off the line so the customer can share their information with the advisor.',
      open: 'If the lead was submitted over 24 hours ago, escalate this lead to support@powur.com.',
      unqualified: 'Reach out to try to get more business from the customer or sign up more leads. Maintain your relationship with the customer.',
      closed_won: 'Congratulate your customer for signing up with SolarCity!',
      contract_out: 'Follow up with the customer and congratulate them on their decision to ',
      proposal_presented: 'Reach out and ask how the customer\'s proposal went. Encourage them to request a contract.',
      legacy_in_progress: 'The Legacy team will work to regenerate the customer\'s interest. Reach out to the customer if your personal relationship is strong.',
      closed_lost: 'Reach out to the customer to try to get more business or sign up more leads. Maintain your relationship with the customer.',
      unqualified: 'Reach out to the customer to try to get more business or sign up more leads. Maintain your relationship with the customer.',
    }

    // Utility Functions:
    function getLeads(cb) {
      CommonService.execute({
        href: '/u/users/' + $rootScope.currentUser.id + '/leads.json'
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
      if ($scope.leadItem && Object.keys($scope.lead).length) {
        var action = $scope.getAction($scope.leadItem.actions, actionName);
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
      if ($scope.updatingLead !== true) {
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
      getLeads(function(items) {
        $scope.closeForm();
        destroyCarousel('.leads');
        $timeout(function() {
          $scope.leads = items.entities;
          $timeout(function() {
            initCarousel('.leads');
            if (cb) return cb();
            return;
          });
        });
      });
    }

    // Status label text for a given lead object
    $scope.leadPipelineSection.statusText = function(leadItem) {
      if (!leadItem) return;
      if (leadItem.properties.data_status === 'submitted') {
        // if submitted, return sales_status
        return leadItem.properties.sales_status.split('_').join(' ');
      } else {
        // otherwise return data_status
        return leadItem.properties.data_status.split('_').join(' ');
      }
    };

    //  Status icon for a given lead object
    $scope.leadPipelineSection.statusIcon = function(leadItem) {
      if (leadItem.properties.data_status === 'submitted') {
        switch (leadItem.properties.sales_status) {
          case 'proposal':
            return legacyImagePaths.leadInProgress;
          case 'contract':
            return legacyImagePaths.leadInProgress;
          case 'installed':
            return legacyImagePaths.leadClosedWon;
          case 'duplicate':
            return legacyImagePaths.leadOnHold;
          case 'ineligible':
            return legacyImagePaths.leadLost;
          case 'closed_lost':
            return legacyImagePaths.leadLost;
          default:
            return legacyImagePaths.leadInProgress;
        }
      } else {
        switch (leadItem.properties.data_status) {
          case 'incomplete':
            return legacyImagePaths.leadIncomplete;
          case 'ready_to_submit':
            return legacyImagePaths.leadReadyToSubmit;
          case 'ineligible_location':
            return legacyImagePaths.leadIneligibleLocation;
        }
      }
    };

    // Determine whether to show Action Required flag on lead or not
    $scope.leadPipelineSection.actionRequired = function(leadItem) {

    };

    // Return Status Definition from Proposal Status Guide (pdf)
    $scope.leadPipelineSection.statusDefinition = function(leadItem) {

    };

    // Return Powur Advocate Action from Proposal Status Guide (pdf)
    $scope.leadPipelineSection.advocateActionMessage = function(leadItem) {

    };

    // Fill status bar to appropriate level
    $scope.leadPipelineSection.leadStage = function(leadItem) {
      if (leadItem.properties.installed_at) {
        return 4;
      }
      if (leadItem.properties.contracted_at) {
        return 3;
      }
      if (leadItem.properties.converted_at) {
        return 2;
      }
      return 1
    };

    // Return "Likelihood to convert" percentage
    $scope.leadPipelineSection.likelihoodToConvert = function(leadItem) {
      if (leadItem.properties.installed_at) {
        return '100';
      }
      if (leadItem.properties.contracted_at) {
        return '90';
      }
      if (leadItem.properties.converted_at) {
        return '25';
      }
      return '10';
    };

    // Controller Actions:

    // Show Lead
    $scope.leadPipelineSection.showLead = function(leadIndex) {

      resetFormValidations();

      $scope.updatingLead = false;
      var leadId = $scope.leads[leadIndex].properties.id;
      $scope.leadIndex = leadIndex;
      if ($scope.showForm === true && (leadId === $scope.currentLead.id)) {
        $scope.closeForm();
        return;
      } else {
        $scope.showForm = false;
        $scope.drilldownActive = false;
        $scope.currentLeadIndex = leadIndex;

        CommonService.execute({
          href: '/u/leads/' + leadId + '.json'
        }).then(function(item){
          $scope.animateDrilldown();
          if (item.properties.data_status === 'submitted') {
            $timeout( function(){
              $scope.lead = item.properties;
              $scope.leadItem = item;
              $scope.currentLead = item.properties;
              $scope.mode = item.properties.data_status;
            }, 300);
          } else {
            $timeout( function(){
              $scope.formAction = $scope.getAction(item.actions, 'update');
              $scope.leadItem = item;
              $scope.lead = $scope.setFormValues($scope.formAction);
              $scope.lead.productFields = $scope.setProductFields($scope.formAction);
              $scope.currentLead = item.properties;
              $scope.mode = item.properties.data_status;
            }, 300);
          }
        });
      }
    };

    // New Proposal Action
    $scope.leadPipelineSection.newLead = function() {

      resetFormValidations();

      if ($scope.showForm === true && $scope.mode === 'new') {
        $scope.closeForm();
        return;
      } else {
        $scope.showForm = false;
        $scope.drilldownActive = false;
        $scope.animateDrilldown();
        $scope.lead = {};
        $scope.currentLead = {};

        getLeads(function(items){
          $scope.animateDrilldown();

          $timeout( function(){
            $scope.mode = 'new';
            $scope.formAction = $scope.getAction(items.actions, 'create');
            $scope.lead.productFields = $scope.setProductFields($scope.formAction);

          }, 200);
        });
      }
    };

    // Save/Update Proposal Action
    $scope.leadPipelineSection.saveLead = function() {

      resetFormValidations();

      // check validity and submit if valid:
      if ($scope.lead && $('#customers-form')[0].checkValidity()) {
        CommonService.execute($scope.formAction, $scope.lead).then(actionCallback($scope.formAction));
      } else {
        showInvalidFormMessages();
      }
    };

    // Form Validation Methods:

    function resetFormValidations() {
      $scope.leadPipelineSection.isEmailInvalid = false;
      $scope.leadPipelineSection.isFirstNameInvalid = false;
      $scope.leadPipelineSection.isLastNameInvalid = false;
      $scope.leadPipelineSection.isAverageBillInvalid = false;
    }

    function showInvalidFormMessages() {
      // Front-end validations, mainly for Safari. (Chrome/Firefox use built-in HTML5 validations)
      if ($('#new_lead_first_name')[0].checkValidity() === false) {
        $scope.leadPipelineSection.isFirstNameInvalid = true;
      }
      if ($('#new_lead_last_name')[0].checkValidity() === false) {
        $scope.leadPipelineSection.isLastNameInvalid = true;
      }
      if ($('#new_lead_email')[0].checkValidity() === false) {
        $scope.leadPipelineSection.isEmailInvalid = true;
      }
      if ($('#new_lead_average_bill')[0].checkValidity() === false) {
        $scope.leadPipelineSection.isAverageBillInvalid = true;
      }
    }

    function actionCallback(action) {
      return function() {

        // Clear filters when performing an action on a lead
        $scope.leadPipelineSection.clearFilters();

        // Create
        if (action.name === 'create' || action.name === 'delete') {
          refreshCarousel(function() {
            $timeout(function() {
              if (action.name === 'create') {
                $('.leads').data('owlCarousel').goTo(0);
                $scope.leadPipelineSection.showLead(0);
              }
            });
          });

        // Update
        } else if (action.name === 'update') {
          getLeads(function(items) {
            $scope.updatingLead = true;
            $scope.closeForm();
            destroyCarousel('.leads');
            $scope.leads = items.entities;
            $timeout(function() {
              initCarousel('.leads');
              $timeout(function() {
                $('.leads').data('owlCarousel').goTo($scope.leadIndex);
                $scope.leadPipelineSection.showLead($scope.leadIndex);
              });
            });
          });

        // Submit
        } else if (action.name === 'submit') {
          $scope.closeForm();
          $anchorScroll();
          $scope.showModal('This lead was submitted to SolarCity.');
          refreshCarousel();

        // Resend
        } else if (action.name === 'resend') {
          $scope.closeForm();
          $anchorScroll();
          $scope.showModal('This lead email was successfully re-sent to ' +
            $scope.lead.customer + ' at ' +
            $scope.lead.email + '.');
        }
      };
    }

    // Submit Lead to SolarCity Action
    $scope.leadPipelineSection.submit = function() {
      if (confirm('Please confirm that all fields in the customer\'s contact information are correct before proceeding. \n' +
          'Are you sure you want to submit this lead to SolarCity?')) {
        $scope.submitAction = $scope.getAction($scope.leadItem.actions, 'submit');
        if ($scope.submitAction) {
          CommonService.execute($scope.submitAction).then(actionCallback($scope.submitAction));
        } else {
          alert('This lead can\'t be submitted to SolarCity.');
        }
      }
    };

    // Delete Lead Action
    $scope.leadPipelineSection.delete = function() {
      if (confirm('Are you sure you want to delete this lead?')) {
        var deleteAction = $scope.getAction($scope.leadItem.actions, 'delete');
        if (deleteAction) {
          CommonService.execute(deleteAction).then(actionCallback(deleteAction));
        } else {
          alert("This lead can't be deleted.");
        }
      }
    };

    // Resend Email Action
    $scope.leadPipelineSection.resend = function() {
      if (confirm('Are you sure you want to resend the lead email to this customer?')) {
        var resendAction = $scope.getAction($scope.leadItem.actions, 'resend');
        if (resendAction) {
          CommonService.execute(resendAction).then(actionCallback(resendAction));
        } else {
          alert("This lead can't be re-sent.");
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
      $scope.currentLead = {};
      $scope.mode = '';
    };

    // Index Actions

    // Defaults
    $scope.leadPipelineSection.isFiltering = false;
    $scope.leadPipelineSection.indexAction = {};

    // Get Options from Index Action Fields for Sort and Status
    $scope.leadPipelineSection.getOptions = function(indexAction, fieldName) {
      for (var i in indexAction.fields) {
        if (indexAction.fields[i].name === fieldName) {
          return indexAction.fields[i].options;
        }
      }
    };

    // Set Options for Index Action Fields for Sort and Status
    /*
    * This function requires the initial getLeads() request to run (see "getLeads Main Function" below)
    * $scope.leadPipelineSection.indexAction is set within the getLeads() callback
    */
    $scope.$watch('leadPipelineSection.indexAction', function(data) {
      if (!Object.keys(data).length) return;
      $scope.leadPipelineSection.leadSortOptions = $scope.leadPipelineSection.getOptions($scope.leadPipelineSection.indexAction, 'sort');
      $scope.leadPipelineSection.leadSubmittedStatusOptions = $scope.leadPipelineSection.getOptions($scope.leadPipelineSection.indexAction, 'submitted_status');
      $scope.leadPipelineSection.leadDataStatusOptions = $scope.leadPipelineSection.getOptions($scope.leadPipelineSection.indexAction, 'data_status');
      $scope.leadPipelineSection.leadSalesStatusOptions = $scope.leadPipelineSection.getOptions($scope.leadPipelineSection.indexAction, 'sales_status');
    });


    // Clear Sort and Filters
    $scope.leadPipelineSection.clearFilters = function() {
      $scope.leadPipelineSection.leadSort = '';
      $scope.leadPipelineSection.leadSubmittedStatus = '';
      $scope.leadPipelineSection.leadDataStatus = '';
      $scope.leadPipelineSection.leadSalesStatus = '';
      $scope.leadPipelineSection.isFiltering = false;
    };

    // Apply Search
    $scope.leadPipelineSection.search = function(user) {
      if (!$scope.nameQuery.length) return;

      // Clear Sort and Filters when Searching
      $scope.leadPipelineSection.clearFilters();

      function jumpToUser() {
        if(typeof(user) !== 'object') {
          user = $scope.nameQuery[$scope.queryIndex];
          $scope.nameQuery = [];
        }
        for (var i=0; i < $scope.leads.length; i++) {
          if($scope.leads[i].properties.id === user.properties.id) {
            $('#customers-carousel').trigger('owl.jumpTo', i);
            $scope.leadPipelineSection.showLead(i);
          }
        }
      }

      /*
      Carousel must be refreshed with all leads
      in order for owl.jumpTo to be able to jump to
      the index of the user:
      */
      refreshCarousel(jumpToUser);

    };

    // Functions for dropdown search feature:
    $scope.customerSearch = {};
    $scope.nameQuery = [];
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
    };

    $scope.clearQuery = function(i) {
      $scope.focused = true;
      $timeout(function() {
        if(i) $scope.focused = false;
        $scope.queryIndex = 0;
      }, 150);
    };

    $scope.fetchNames = function(){
      if (!$scope.customerSearch.string) {
        $scope.queryIndex = 0;
        return $scope.nameQuery = [];
      }
      CommonService.execute({
        href: '/u/users/' + $rootScope.currentUser.id + '/leads.json',
        params: {search: $scope.customerSearch.string, limit: 7}
      }).then(function(items){
        $scope.nameQuery = items.entities;
        $timeout(function() {
          $('.left-label').wrapInTag({
            tag: 'span class="highlight"',
            words: [$scope.customerSearch.string]
          });
        });
       
      });
    };

    // Apply Sort/Status
    $scope.leadPipelineSection.applyIndexActions = function() {
      /*
      leadPipelineSection.isFiltering is used to determine which "empty" state
      to display on the carousel when no there are no leads.
      */
      $scope.leadPipelineSection.isFiltering = true;

      /*
      Switch statement to clear leadDataStatus or leadSalesStatus
      from the query when user changes leadSubmittedStatus value:
      */
      switch ($scope.leadPipelineSection.leadSubmittedStatus) {
        case 'not_submitted':
          $scope.leadPipelineSection.leadSalesStatus = '';
          break;
        case 'submitted':
          $scope.leadPipelineSection.leadDataStatus = '';
          break;
        case '':
          $scope.leadPipelineSection.leadDataStatus = '';
          $scope.leadPipelineSection.leadSalesStatus = '';
          break;
      }

      // Assign filters from select dropdowns
      var data = {
        sort: $scope.leadPipelineSection.leadSort,
        submitted_status: $scope.leadPipelineSection.leadSubmittedStatus,
        data_status: $scope.leadPipelineSection.leadDataStatus,
        sales_status: $scope.leadPipelineSection.leadSalesStatus
      };

      var href = '/u/users/' + $rootScope.currentUser.id + '/leads';

      $scope.closeForm();
      destroyCarousel('.leads');

      $http({
        method: 'GET',
        url: href,
        params: data,
      }).success(function(items) {
        $scope.leads = items.entities;
        $timeout(function() {
          initCarousel('.leads');
        });
      });
    };


    // getLeads Main Function
    /*
    * The carousel needs $rootScope.currentUser.id when it calls the endpoint (/u/users/:userId/leads.json)
    * This watches $rootScope.currentUser then calls getLeads() when it has an object
    */
    $rootScope.$watch('currentUser', function(data) {
      if (!Object.keys(data).length) return;

      getLeads(function(items) {
        // Set Leads
        $scope.leads = items.entities;
        // Set Index Action
        $scope.leadPipelineSection.indexAction = $scope.getAction(items.actions, 'index');
        // Initialize Leads Carousel
        $timeout(function(){
          initCarousel('.leads');
        });
      });
    });
  }

  DashboardLeadPipelineCtrl.$inject = ['$scope', '$rootScope', '$location', '$http', '$timeout', '$route', '$anchorScroll', 'CommonService'];
  angular
    .module('powurApp')
    .controller('DashboardLeadPipelineCtrl', DashboardLeadPipelineCtrl);
})();
