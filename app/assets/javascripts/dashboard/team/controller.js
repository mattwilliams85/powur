;(function() {
  'use strict';

  function DashboardTeamCtrl($rootScope, $scope, $timeout, $http, User, CommonService) {
    $scope.redirectUnlessSignedIn();
    $scope.showInvitesCarousel = false;

    $scope.legacyImagePaths = legacyImagePaths;
    $scope.downline = [];
    $scope.currentTeamMember = {};

    var level;

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
        lazyLoad: true,
        beforeMove: owlCloseForm(carouselElement)
      });
    }

    // Close Team Member Show when Moving Carousel
    function owlCloseForm(element) {
      return function() {
        $timeout(function() {
          closeForm(element);
        });
      };
    }

    // Device Detection
    $scope.isMobile = function() {
      if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
       return true;
      }
    };

    $scope.isActiveTab = function(teamMember, gen, tab) {
     if (tab) return gen.tab === tab && gen.selected === teamMember.properties.id && $scope.activeTab === tab;
     return ($scope.downline.length > ($scope.levelGap(teamMember))) && gen.selected === teamMember.properties.id;
    };

    $scope.isActiveMember = function(teamMember, gen) {
      return (gen.selected === teamMember.properties.id);
    }

    $scope.toggleProposal = function(proposal) {
      if (!proposal || $scope.proposalId === proposal.properties.id) {
        $scope.proposalId = '';
        return $scope.showProposal = false;
      }
      $scope.showProposal = true;
      $scope.proposalId = proposal.properties.id;
    }

    // Close Team Member
    function closeForm(element) {
      if(element && element.attr('data-row')) {
        $scope.downline = $scope.downline.slice(0, parseInt(element.attr('data-row')) + 1);
        $scope.downline[$scope.downline.length - 1].selected = "";
        $scope.activeTab = '';
      }
      $scope.proposalId = '';
      $scope.showProposal = false;
      $scope.currentTeamMember = {};
    };

    function destroyCarousel(carouselElement) {
      if ( !$(carouselElement).data('owlCarousel') ) return;
      $(carouselElement).data('owlCarousel').destroy();
    }

    function setAvatar(items) {
      for (var i = 0; i < items.entities.length; i++){
        if (items.entities[i].properties.avatar) continue;
        items.entities[i].properties.avatar = [];
        items.entities[i].properties.avatar.thumb = legacyImagePaths.defaultAvatarThumb[Math.floor(Math.random() * 3) ];
      }
      return items;
    }

    function teamTab(teamMember) {
      $scope.disable = true;
      User.downline(teamMember.id, {sort: $scope.teamSection.teamSort}).then(function(items) {
        items = setAvatar(items);

        $timeout(function(){
          $scope.activeTab = 'team'
          $scope.downline = $scope.downline.slice(0, $scope.levelGap(teamMember));
          $scope.downline.push(items.entities);
          destroyCarousel('#carousel-' + ($scope.downline.length - 1))
          $scope.disable = false;

        });
      });
    }

    // Show Team Member
    $scope.changeTab = function(teamMember, gen, tab) {
      if ($scope.disable) return;

      // Delay for transition between multiple animations
      var delay = 300;
      if (!$scope.activeTab) delay = 0;

      if($scope.currentTeamMember.id === teamMember.id && $scope.activeTab === tab) {
        gen.selected = null;
        gen.tab = null;
        $scope.downline = $scope.downline.slice(0, $scope.levelGap(teamMember));
        closeForm();
        return $scope.activeTab = '';
      } else {
        gen.selected = teamMember.id;
        console.log(gen.selected)
        gen.tab = tab;
        closeForm();

        $scope.currentTeamMember = teamMember;

        if (tab === 'team') {
          teamTab(teamMember);
        } else {
          $scope.activeTab = tab;
          $timeout(function(){
            $scope.downline = $scope.downline.slice(0, $scope.levelGap(teamMember));
          }, delay);
        }
      }
    };

    $scope.invitesTab = function() {
      if ($scope.activeTab === 'invites') return closeForm();
      $scope.activeTab = 'invites';
      CommonService.execute({href: '/u/invites.json'}).then(function(data){
      });
    }

    $scope.levelGap = function(teamMember) {
      if(teamMember.properties) return teamMember.properties.level - level;
      return teamMember.level - level;
    };

    //On ng-repeat load
    $scope.onEnd = function(){
      $timeout(function(){
        initCarousel($('#carousel-' + ($scope.downline.length - 1)));
      });
    };

    // Search Action
    $scope.teamSection.teamSearch = '';

    $scope.teamSection.search = function() {
      for (var i = 0; i < $scope.downline.length; i++){
        destroyCarousel('#carousel-'+ i);
      }
      var searchQuery = {search: $scope.teamSection.teamSearch};
      User.downline($rootScope.currentUser.id, searchQuery).then(function(items) {
        setAvatar(items);
        $scope.downline = [items.entities];
        $timeout(function() {
          initCarousel($('#carousel-0'));
          closeForm($('#carousel-0'));
        });
      });
    };

    // Sort Action
    $scope.teamSection.teamSort = 'name';

    $scope.teamSection.sort = function() {
      closeForm($('#carousel-0'));
      var sortQuery = {sort: $scope.teamSection.teamSort};
      for (var i = 0; i < $scope.downline.length; i++){
        destroyCarousel('#carousel-'+ i);
      }

      User.downline($rootScope.currentUser.id, {sort: $scope.teamSection.teamSort}).then(function(items) {
        setAvatar(items);
        $scope.downline = [items.entities];
        $timeout(function() {
          initCarousel($('#carousel-0'));
        });
      });
    };

    // Apply Search
    $scope.teamSection.searchProposals = function () {
      $scope.teamSection.proposalSort = '';
      $scope.teamSection.proposalStatus = '';
      $scope.teamSection.applyIndexActions();
      if ($scope.teamSection.proposalSearch === '') {
        $scope.teamSection.searching = false;
      } else {
        $scope.teamSection.searching = true;
      }
    };

    $scope.teamSection.applyIndexActions = function() {
      var data = {
        sort: $scope.teamSection.proposalSort,
        status: $scope.teamSection.proposalStatus
      };
      if ($scope.teamSection.proposalSearch) {
        data.search = $scope.teamSection.proposalSearch;
      }
      if ($scope.teamSection.proposalStatus !== '') {
        $scope.teamSection.searching = true;
      }

      var href = '/u/users/' + $scope.teamId + '/quotes'
      closeForm();
      destroyCarousel('#teamProposals');

      $http({
        method: 'GET',
        url: href,
        params: data,
      }).success(function(items) {
        $scope.teamProposals = items.entities;
        $timeout(function() {
          initCarousel($('#teamProposals'));
        });
      });
    };

    $scope.teamSection.fetchProposals = function(teamMember) {
      $scope.teamId = teamMember.properties.id
      CommonService.execute({
        href: '/u/users/' + teamMember.properties.id + '/quotes.json'
      }).then(function(items){
        // Set Proposals
        $scope.teamProposals = items.entities;
        // Set Index Action
        // $scope.customerSection.indexAction = $scope.getAction(items.actions, 'index');
        // Initialize Proposals Carousel
        destroyCarousel('#teamProposals');
        $timeout(function(){
          initCarousel($('#teamProposals'));
        });
      })
    }

    // Show Proposal
    $scope.teamSection.showProposal = function(proposal) {
      CommonService.execute({
        href: '/u/quotes/' + proposal.properties.id + '.json'
      }).then(function(item){
        $scope.updates = item.entities;
        $scope.activeProposal = item.properties;
      });
    };


    // Fetch User's Immediate downline
    $rootScope.$watch('currentUser', function(data) {
      if (!data || !data.id) return;
      return User.downline(data.id, {sort: $scope.teamSection.teamSort}).then(function(items) {
        items = setAvatar(items);

        $scope.downline.push(items.entities);
        $timeout(function() {
          initCarousel($('#carousel-0'));
          level = $scope.currentUser.level;
        });
      });
    });

  }

  DashboardTeamCtrl.$inject = ['$rootScope', '$scope', '$timeout', '$http', 'User', 'CommonService'];
  angular.module('powurApp').controller('DashboardTeamCtrl', DashboardTeamCtrl)
  .directive('repeatEnd', function(){
    return {
      restrict: 'A',
        link: function (scope, element, attrs) {
          if (scope.$last) {
            scope.$eval(attrs.repeatEnd);
          }
        }
      };
  });
})();
