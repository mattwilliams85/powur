;(function() {
  'use strict';

  function DashboardTeamCtrl($rootScope, $scope, $timeout, $http, $location, User, CommonService) {
    $scope.redirectUnlessSignedIn();

    $scope.showInvitesCarousel = false;
    $scope.img = legacyImagePaths;
    $scope.downline = [];
    $scope.currentTeamMember = {};
    $scope.nameQuery = [];
    $scope.queryIndex = 0;
    $scope.dQueue = [];
    $scope.teamSearch = {};

    //Conditional Ref Object
    $scope.is = {
      even: function(i) {
        return levelGap(i) % 2 !== 0
      },
      odd: function(i) {
        return levelGap(i) % 2 === 0
      },
      expanded: function(i) {
        return $scope.downline.length >= (i)
      },
      accordion: function(i) {
        var gap = 2
        if ($scope.activeTab === 'proposals' || $scope.activeTab === 'info') gap = 1
        return $scope.downline.length > (i + gap)
      },
      activeTab: function(member, gen, tab) {
        return gen.tab === tab && gen.selected === member.id;
      },
      activeMember: function(member, gen) {
        return (gen.selected === member.id);
      }
    }

    function levelGap(member) {
      if(member) return member.level - level;
    };

    // Device Detection
    $scope.isMobile = function() {
      if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
       return true;
      }
    };

//OWL-CAROUSEL
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
        beforeMove: owlCloseTabs(carouselElement)
      });
    }

    function destroyCarousel(carouselElement) {
      if (!$(carouselElement).data('owlCarousel')) return;
      $(carouselElement).data('owlCarousel').destroy();
    }

    // Close Team Member Show when Moving Carousel
    function owlCloseTabs(element) {
      return function() {
      if ($scope.jumping) return;
        $timeout(function() {
          closeTabs(element);
        });
      };
    }

//TABS
    function closeTabs(element) {
      if(element && element.attr('data-row')) {
        $scope.downline = $scope.downline.slice(0, parseInt(element.attr('data-row')) + 1);
        $scope.downline[$scope.downline.length - 1].selected = "";
        $scope.activeTab = '';
      }
      $scope.proposalId = null;
      $scope.showProposal = false;
      $scope.showNew = false;
      $scope.activeInvite = '';
      $scope.currentTeamMember = {};
    }

    function closeAllTabs() {
      $scope.downline = [$scope.downline[0]];
      $scope.downline[0].selected = null;
      $scope.downline[0].tab = null;
      $scope.activeTab = '';
      closeTabs();
    }

    $scope.changeTab = function(member, gen, tab) {
      if ($scope.disable) return;

      var delay = 300; // Delay for transition between multiple animations
      if (!$scope.activeTab) delay = 0;

      if($scope.currentTeamMember.id === member.id && $scope.activeTab === tab) {
        gen.selected = null;
        gen.tab = null;
        $scope.downline = $scope.downline.slice(0, levelGap(member));
        closeTabs();
        return $scope.activeTab = '';
      } else {
        gen.selected = member.id;
        gen.tab = tab;
        closeTabs();

        $scope.currentTeamMember = member;

        if (tab === 'team') {
          teamTab(member);
        } else {
          $timeout(function(){
            $scope.activeTab = tab;
            $scope.downline = $scope.downline.slice(0, levelGap(member));
          }, delay);
        }
      }
    };

    function teamTab(member) {
      $scope.disable = true;

      User.downline(member.id, {sort: $scope.teamSection.teamSort}).then(function(items) {
        items = initDownline(items);
        $timeout(function(){
          $scope.activeTab = 'team'
          $scope.downline = $scope.downline.slice(0, levelGap(member));
          $scope.downline.push(items.entities);
          destroyCarousel('#carousel-' + ($scope.downline.length - 1))
          $scope.disable = false;
        });
      });
    }

    function initDownline(items) {
      for (var i = 0; i < items.entities.length; i++){
        items.entities[i] = items.entities[i].properties;
        if (items.entities[i].avatar) continue;
        items.entities[i].avatar = [];
        items.entities[i].avatar.thumb = legacyImagePaths.defaultAvatarThumb[Math.floor(Math.random() * 3) ];
      }
      return items;
    }

    $scope.invitesTab = function() {
      if ($scope.noInvitesAvailable && !$scope.invites.length && !$scope.invites.redeemed) return $location.path('/upgrade');
      closeAllTabs();
      if ($scope.activeTab === 'invites') {
        $scope.activeTab = '';
        return closeTabs();
      }
      closeTabs();
      $scope.activeTab = 'invites';
    };

    //Init&Jump Carousel on ng-repeat end
    $scope.onEnd = function(index){
      $timeout(function(){
        initCarousel($('#carousel-' + (index)));
        if ($scope.downline[index].selected) {
          jumpTo($scope.downline[index].selected, index);
        }
        if (index + 1 === $scope.dQueue.length || !$scope.dQueue.length) {
          $timeout(function(){
            $scope.jumping = false;
            $('html, body').animate({
                scrollTop: $("#carousel-" + index).offset().top - 300
            }, 10);
          }, 10);
        }
      });
    };

    //Jump to active carousel member
    function jumpTo(id, index){
      for (var i=0; i < $scope.downline[index].length; i++) {
        if ($scope.downline[index][i].id === id) { 
          $('#carousel-' + index).trigger('owl.jumpTo', i)
        }
      }
    }

//SEARCH
    $scope.key = function(key){
      if (key === parseInt(key, 10)) return $scope.queryIndex = key;
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
        $scope.queryIndex = 0;
        if(i) $scope.focused = false;
      }, 150)    
    }

    $scope.fetchNames = function(){
      if (!$scope.teamSearch.string) {
        $scope.queryIndex = 0;
        return $scope.nameQuery = [];
      }
      CommonService.execute({
        href: '/u/users/' + $rootScope.currentUser.id + '/full_downline.json',
        params: {search: $scope.teamSearch.string}
      }).then(function(items){
        $scope.nameQuery = initDownline(items).entities;
        $timeout(function() {
          $('.left-label').wrapInTag({
            tag: 'span class="highlight"',
            words: [$scope.teamSearch.string]
          });
        })
       
      });
    }

    var dCount;

    $scope.teamSection.search = function(user) {
      closeAllTabs();
      if (!$scope.nameQuery.length && !user) return;
      
      if (!$scope.nameQuery.length) {
        return $scope.nameQuery = [];
      }
      if(typeof(user) != 'object') {
        user = $scope.nameQuery[$scope.queryIndex];
        $scope.nameQuery = [];
      }

      $('#team-search').val(user.first_name + ' ' + user.last_name).blur();
      $scope.downline = [$scope.downline[0]];
      dCount = 0;
      $scope.dQueue = [];
      fetchDownline(user)
    }

    function fetchDownline(user) {
      $scope.currentTeamMember = user;
      $scope.jumping = true;
      $scope.downline[0].selected = user.upline[1];

      if (dCount + 2 === user.upline.length) return populateDownline(user);

      User.downline(user.upline[dCount+1], {sort: $scope.teamSection.teamSort}).then(function(items) {
        dCount += 1;
        items = initDownline(items);
        $scope.activeTab = 'team'
        $scope.dQueue.push(items.entities);
        fetchDownline(user)
      });
    }

    function populateDownline(user) {
      for(var i = 0; i < $scope.dQueue.length; i++) {
        $scope.downline.push($scope.dQueue[i])
        $scope.downline[i].selected = user.upline[i+1];
        $scope.downline[i].tab = 'team';
      }
      //Sets the last user's tab to info
      $scope.onEnd(0);
      $scope.downline[$scope.downline.length - 1].selected = user.upline[user.upline.length - 1]
      $scope.activeTab = 'info';
      $scope.downline[dCount].tab = 'info';
      return;
    }

//SORT
    $scope.teamSection.teamSort = 'name';

    $scope.teamSection.sort = function() {
      closeTabs($('#carousel-0'));
      for (var i = 0; i < $scope.downline.length; i++){
        destroyCarousel('#carousel-'+ i);
      }

      User.downline($rootScope.currentUser.id, {sort: $scope.teamSection.teamSort}).then(function(items) {
        initDownline(items);
        $scope.downline = [items.entities];
        $timeout(function() {
          initCarousel($('#carousel-0'));
        });
      });
    };

//PROPOSALS
    $scope.teamSection.fetchProposals = function(member) {
      $scope.teamId = member.id;
      CommonService.execute({
        href: '/u/users/' + member.id + '/quotes.json'
      }).then(function(items){
        $scope.teamProposals = items.entities;
        destroyCarousel('#teamProposals');
        $timeout(function(){
          initCarousel($('#teamProposals'));
        });
      });
    };

    $scope.teamSection.showProposal = function(proposal) {
      if (!proposal || $scope.proposalId === proposal.properties.id) {
        $scope.proposalId = '';
        return $scope.showProposal = false;
      }
      $scope.showProposal = true;
      $scope.proposalId = proposal.properties.id;

      CommonService.execute({
        href: '/u/quotes/' + proposal.properties.id + '.json'
      }).then(function(item){
        $scope.updates = item.entities;
        $scope.activeProposal = item.properties;
      });
    };

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

      var href = '/u/users/' + $scope.teamId + '/quotes';
      closeTabs();
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

//INVITES
    $scope.inviteExpired = function(invite) {
      var now = new Date();
      if (invite) {
        var expiration = new Date(Date.parse(invite.properties.expires));
        if (expiration <= now) {
          return true;
        }
      }
      return false;
    };

    // Show Invite
    $scope.showInvite = function(invite) {
      if ($scope.activeInvite === invite) return closeTabs();
      closeTabs();
      $scope.activeInvite = invite;
    };

    $scope.newInvite = function() {
      if ($scope.showNew) return closeTabs();
      closeTabs();
      if ($scope.noInvitesAvailable) return;
      $scope.showNew = true;
      $scope.newInviteFields = {};
      $scope.error = {};
    };

    function fetchInvites() {
      CommonService.execute({href: '/u/invites.json'}).then(function(data){
        $scope.invites = data.entities;
        $scope.invites.available = data.properties.available;
        $scope.invites.redeemed = data.properties.redeemed.length;
        $scope.inviteFormAction = getAction(data.actions, 'create');
        $scope.noInvitesAvailable = false;
        if (!$scope.invites.available) {
          $scope.noInvitesAvailable = true;
        }
        destroyCarousel('#invites');
        $timeout(function(){
          initCarousel($('#invites'));
        });
      });
    };

    $scope.sendNewInvite = function() {
      if ($scope.newInviteFields) {
        CommonService.execute($scope.inviteFormAction, $scope.newInviteFields).then(function success(data){
          if (data.error) {
            $scope.error = data.error;
            return;
          }
          $scope.invites.unshift(data);
          destroyCarousel('#invites');
          $timeout(function(){
            initCarousel($('#invites'));
          });
          $scope.invites.available -= 1;
          if ($scope.invites.available === 0) {
            $scope.noInvitesAvailable = true;
          }
          closeTabs();
        });
      }
    };

    $scope.resendInvite = function(invite) {
      var resendAction = getAction(invite.actions, 'resend');
      CommonService.execute(resendAction).then(function(data) {
        fetchInvites();
        closeTabs();
      });
    };

    $scope.deleteInvite = function(invite) {
      var deleteAction = getAction(invite.actions, 'delete');
      if (confirm('Are you sure you want to cancel ' + invite.properties.first_name + ' ' + invite.properties.last_name + '\'s invite?')) {
        CommonService.execute(deleteAction).then(function() {
          fetchInvites();
          closeTabs();
        });
      }
    };

    // Get an action with a given name
    function getAction(actions, name) {
      for (var i in actions) {
        if (actions[i].name === name) {
          return actions[i];
        }
      }
      return;
    }

//ON PAGE LOAD
    var level;
    // Fetch User's Immediate downline
    $rootScope.$watch('currentUser', function(data) {
      if (!data || !data.id) return;
      return User.downline(data.id, {sort: $scope.teamSection.teamSort}).then(function(items) {
        items = initDownline(items);

        $scope.downline.push(items.entities);
        $timeout(function() {
          initCarousel($('#carousel-0'));
          level = $scope.currentUser.level;
        });
      });
    });

    $timeout(function() {
      fetchInvites();
    });
  }

  DashboardTeamCtrl.$inject = ['$rootScope', '$scope', '$timeout', '$http', '$location', 'User', 'CommonService'];
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
