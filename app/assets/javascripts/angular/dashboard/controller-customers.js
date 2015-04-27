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
      formValues[key] = (value);
    }
    return formValues;
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
    }
  };

  // Submit Proposal to SolarCity Action
  $scope.submit = function() {
    $scope.submitAction = $scope.getAction($scope.proposalItem.actions, 'submit');
    Customer.execute($scope.submitAction).then(actionCallback($scope.submitAction()));
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
