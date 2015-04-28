'use strict';

function DashboardCustomersCtrl($scope, $location, $timeout, $route, Geo, Customer) {
  $scope.redirectUnlessSignedIn();
  $scope.states = Geo.states();
  $scope.slickApply = {};

  // Utility Functions:
  $scope.getAction = function(actions, name) {
    for (var i in actions) {
      if (actions[i].name === name) {
        return actions[i];
      }
    }
    return;
  };

  $scope.setFormValues = function(formAction) {
    var formValues = {};
    for (var i in formAction.fields) {
      var key = formAction.fields[i].name;
      var value = formAction.fields[i].value;
      formValues[key] = (value) || '';
    }
    return formValues;
  };

  $scope.setProductFields = function(formAction) {
    var productFields = [];
    for (var i in formAction.fields) {
      if (formAction.fields[i].product_field) {
        productFields.push(formAction.fields[i]);
      }
    }
    return productFields;
  };

  $scope.sanitizeLabel = function(fieldNameString) {
    var sanitizedString = fieldNameString.replace(/_/g, " ");
    return sanitizedString;
  };

  var slick = function(elementToSlick) {
    $(elementToSlick).slick({
      swipe: false,
      dots: false,
      infinite: true,
      speed: 300,
      slidesToShow: 4,
      slidesToScroll: 4,
      prevArrow: '<a class="slick-prev"><i class="fa fa-chevron-left"></i></a>',
      nextArrow: '<a class="slick-next"><i class="fa fa-chevron-right"></i></a>',
      responsive: [
        {
          breakpoint: 1024,
          settings: {
            slidesToShow: 3,
            slidesToScroll: 3,
          }
        },
        {
          breakpoint: 768,
          settings: {
            slidesToShow: 2,
            slidesToScroll: 2
          }
        }
      ]
    });
  };

  // Show Proposal
  $scope.showProposal = function(proposalIndex) {
    var proposalId = $scope.proposals[proposalIndex].properties.id;
    if ($scope.showForm === true && (proposalId === $scope.currentProposal.id)) {
      $scope.closeForm();
    } else {
      $scope.proposal = {};
      $scope.currentProposal = {};
      $scope.currentProposalIndex = proposalIndex;

      Customer.get(proposalId).then(function(item){
        if ($scope.getAction(item.actions, 'update')) {
          $scope.formAction = $scope.getAction(item.actions, 'update');
          $scope.proposalItem = item;
          $scope.proposal = $scope.setFormValues($scope.formAction);
          $scope.proposal.productFields = $scope.setProductFields($scope.formAction);
          $scope.currentProposal = item.properties;
          $scope.mode = 'incomplete';
          $scope.showForm = true;
        } else {
          $scope.proposal = item.properties;
          $scope.currentProposal = item.properties;
          $scope.mode = 'submitted';
          $scope.showForm = true;
        }
      });
    }
  };

  // New Proposal
  $scope.newProposal = function() {
    if ($scope.showForm === true && $scope.mode === 'new') {
      $scope.closeForm();
    } else {
      $scope.proposal = {};
      $scope.currentProposal = {};

      Customer.list().then(function(items){
        $scope.formAction = $scope.getAction(items.actions, 'create');
        $scope.proposal.productFields = $scope.setProductFields($scope.formAction);
        $scope.mode = 'new';
        $scope.showForm = true;
      });
    }
  };

  // Save/Update Action
  $scope.saveProposal = function() {
    if ($scope.proposal) {
      Customer.execute($scope.formAction, $scope.proposal).then(actionCallback($scope.formAction));
    }
  };

  function updateSlickCarousel(data, index) {
    // If index, set newValues to the properties of this proposal; otherwise {}
    var newValues = (index >= 0) ? $scope.proposals[index].properties : {};
    newValues.customer = data.first_name + ' ' + data.last_name;
    if (index >= 0) {
      $scope.proposals[index].properties = newValues;
    } else {
      // Workaround for carousel not taking new values...
      $route.reload();
      slick('.carousel');
      $scope.showModal('Your new proposal was successfully created!');
    }
  }

  var actionCallback = function(action) {
    if (action.name === 'create') {
      updateSlickCarousel($scope.proposal);
      $scope.closeForm();
    } else if (action.name === 'update') {
      updateSlickCarousel($scope.proposal, $scope.currentProposalIndex);
      $scope.closeForm();
    } else if (action.name === 'submit') {
      console.log('submitted proposal!');
      $scope.closeForm();
    } else if (action.name === 'delete') {
      $route.reload();
      slick('.carousel');
      $scope.showModal('The proposal you selected was successfully deleted.');
    } else if (action.name === 'resend') {
      $route.reload();
      $scope.showModal('This proposal email was successfully resent to ' +
        $scope.proposal.first_name + ' ' +
        $scope.proposal.last_name + ' at ' +
        $scope.proposal.email + '.');
    }
  };

  // Submit Proposal to SolarCity Action
  $scope.submit = function() {
    if (confirm('Please confirm that all fields in the customer\'s contact information are correct before proceeding. \n' +
        'Are you sure you want to submit this proposal to SolarCity?')) {
      if ($scope.submitAction = $scope.getAction($scope.proposalItem.actions, 'submit')) {
        Customer.execute($scope.submitAction).then(actionCallback($scope.submitAction()));
      } else {
        alert('This proposal can\'t be submitted to SolarCity.');
      }
    }
  };

  // Delete Proposal Action
  $scope.delete = function() {
    if (confirm('Are you sure you want to delete this proposal?')) {
      var deleteAction = $scope.getAction($scope.proposalItem.actions, 'delete');
      if (deleteAction) {
        Customer.execute(deleteAction).then(actionCallback(deleteAction));
      } else {
        alert("This proposal can't be deleted.");
      }
    }
  };

  // Resend Email Action
  $scope.resend = function() {
    if (confirm('Are you sure you want to resend the proposal email to this customer?')) {
      var resendAction = $scope.getAction($scope.proposalItem.actions, 'resend');
      if (resendAction) {
        Customer.execute(resendAction).then(actionCallback(resendAction));
      } else {
        alert("This proposal can't be resent.");
      }
    }
  };

  // Close Form
  $scope.closeForm = function() {
    $scope.showForm = false;
    $scope.mode = '';
    $scope.currentProposal = {};
    // $scope.$apply();
  };

  return Customer.list().then(function(items) {
    $scope.proposals = items.entities;
    $timeout(function(){
      slick('.carousel');
    });
  });

}


DashboardCustomersCtrl.$inject = ['$scope', '$location', '$timeout', '$route', 'Geo', 'Customer'];
sunstandControllers.controller('DashboardCustomersCtrl', DashboardCustomersCtrl);
