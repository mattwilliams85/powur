;(function() {
  'use strict';

  function DashboardTeamCtrl($rootScope, $scope, $timeout, $interval,
                             $http, $location, User, CommonService) {

    $scope.redirectUnlessSignedIn();

    $scope.showInvitesCarousel = false;
    $scope.img = legacyImagePaths;
    $scope.downline = [];
    $scope.activeUser = {};
    $scope.nameQuery = [];
    $scope.queryIndex = 0;
    $scope.dQueue = [];
    $scope.teamSearch = {};
    $scope.placement = {};
    $scope.sort = {};

    //Conditional Ref Object
    $scope.is = {
      even: function(i) {
        return levelGap(i) % 2 !== 0;
      },
      odd: function(i) {
        return levelGap(i) % 2 === 0;
      },
      expanded: function(i) {
        return $scope.downline.length >= (i);
      },
      accordion: function(i) {
        var gap = 2;
        if ($scope.activeTab === 'proposals' ||
            $scope.activeTab === 'info') gap = 1;
        return $scope.downline.length > (i + gap);
      },
      activeTab: function(member, gen, tab) {
        return gen.tab === tab && gen.selected === member.id;
      },
      activeMember: function(member, gen) {
        return (gen.selected === member.id);
      },
      inactiveTeamTab: function(member) {
        if ($scope.placement.child) {
          return !member.totals.team_count ||
                  member.id === $scope.placement.child.id;
        }
        return !member.totals.team_count;
      },
      unrelated: function(member, hover) {
        if ($scope.placement.child) {
          return hover === true &&
                 $scope.placement.on &&
                 member.id !== $scope.placement.child.id &&
                 member.id !== parentId($scope.placement.child);
        }
      },
      placeable: function(member) {
        if (member.sponsor_id !== $scope.currentUser.id ||
            member.moved) return;
        var startDate = new Date(member.created_at);
        var betaStart = new Date('Mon Jul 30 2015 10:41:08 GMT-0700 (PDT)');
        if (startDate < betaStart) startDate = betaStart;
        return startDate.addDays(60) > new Date();
      },
    };

    function parentId(member) {
      if (!member.upline) return;
      return member.upline[member.upline.length - 2];
    }

    function levelGap(member) {
      if(member) return member.level - level;
    }

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
        var row = parseInt(element.attr('data-row'));
        $scope.downline = $scope.downline.slice(0, row + 1);
        $scope.downline[$scope.downline.length - 1].selected = '';
        $scope.activeTab = '';
      }
      $scope.leadId = null;
      $scope.showProposal = false;
      $scope.showNew = false;
      $scope.activeInvite = '';
      $scope.activeUser = {};
    }

    function closeAllTabs() {
      $scope.downline = [$scope.downline[0]];
      $scope.downline[0].selected = null;
      $scope.downline[0].tab = null;
      $scope.activeTab = '';
      closeTabs();
    }

    $scope.changeTab = function(member, gen, tab) {
      if ($scope.disable || $scope.placement.parent) return;
      $scope.teamSection.proposalSort = '';
      $scope.teamSection.proposalStatus = '';

      var delay = 300; // Delay for transition between multiple animations
      if (!$scope.activeTab) delay = 0;

      if($scope.activeUser.id === member.id && $scope.activeTab === tab) {
        gen.selected = null;
        gen.tab = null;
        $scope.downline = $scope.downline.slice(0, levelGap(member));
        closeTabs();
        $scope.activeTab = '';
        return;
      } else {
        gen.selected = member.id;
        gen.tab = tab;
        closeTabs();


        if (tab === 'info') {
          fetchUser(member, delay);
        } else {
          $scope.activeUser = member;
        }

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

    function fetchUser(member, delay) {
      $scope.activeUser.changing = true;
        CommonService.execute({
          href: '/u/users/' + member.id + '.json?user_totals=true',
          params: {search: $scope.teamSearch.string}
        }).then(function(items){
          $timeout(function(){
            $scope.activeUser = items.properties;
            $scope.activeUser.changing = false;
            $scope.totals = items.properties.totals;
          }, delay);
        });
    }

    function teamTab(member) {
      $scope.disable = true;

      User.downline(member.id, {sort: $scope.sort.type}).then(function(items) {
        items = initDownline(items);
        $timeout(function(){
          $scope.activeTab = 'team';
          $scope.downline = $scope.downline.slice(0, levelGap(member));
          $scope.downline.push(items.entities);
          destroyCarousel('#carousel-' + ($scope.downline.length - 1));
          $scope.disable = false;
        });
      });
    }

    function initDownline(items) {
      for (var i = 0; i < items.entities.length; i++){
        items.entities[i] = items.entities[i].properties;
        if (items.entities[i].avatar) continue;
        items.entities[i].avatar = [];
        var rand = Math.floor(Math.random() * 3);
        items.entities[i].avatar.thumb = $scope.img.defaultAvatarThumb[rand];
      }
      return items;
    }

    $scope.invitesTab = function() {
      if ($scope.noInvitesAvailable &&
          !$scope.invites.length &&
          !$scope.invites.redeemed) return $location.path('/upgrade');
      if ($scope.activeTab === 'invites') {
        $scope.activeTab = '';
        return closeAllTabs();
      }
      closeAllTabs();
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
                scrollTop: $('#carousel-' + index).offset().top - 300
            }, 10);
          }, 10);
        }
      });
    };

    //Jump to active carousel member
    function jumpTo(id, index){
      for (var i=0; i < $scope.downline[index].length; i++) {
        if ($scope.downline[index][i].id === id) {
          $('#carousel-' + index).trigger('owl.jumpTo', i);
        }
      }
    }

//SEARCH
    $scope.key = function(key){
      if (key === parseInt(key, 10)) {
        $scope.queryIndex = key;
        return;
      }
      if (!$scope.nameQuery.length) return;

      if (key.keyCode === 38) {
        if ($scope.queryIndex < 1) return;
        $scope.queryIndex -= 1;
      } else if (key.keyCode === 40) {
        if( $scope.queryIndex + 1 === $scope.nameQuery.length) return;
        $scope.queryIndex += 1;
      }
    };

    $scope.clearQuery = function(i) {
      $scope.focused = true;
      $timeout(function() {
        $scope.queryIndex = 0;
        if(i) $scope.focused = false;
      }, 150);
    };

    $scope.fetchNames = function(){
      if (!$scope.teamSearch.string) {
        $scope.queryIndex = 0;
        $scope.nameQuery = [];
        return;
      }
      CommonService.execute({
        href: '/u/users/' + $rootScope.currentUser.id + '/full_downline.json',
        params: {search: $scope.teamSearch.string}
      }).then(function(items){
        $scope.nameQuery = initDownline(items).entities;
        $timeout(function() {
          $('.left-label, .bottom-label').wrapInTag({
            tag: 'span class="highlight"',
            words: [$scope.teamSearch.string]
          });
        });

      });
    };

    var dCount;

    $scope.teamSection.search = function(user) {
      closeAllTabs();
      if (!$scope.nameQuery.length && !user) return;

      if (!$scope.nameQuery.length) {
        $scope.nameQuery = [];
        return;
      }
      if(typeof(user) !== 'object') {
        user = $scope.nameQuery[$scope.queryIndex];
        $scope.nameQuery = [];
      }

      $('#team-search').val(user.first_name + ' ' + user.last_name).blur();
      $scope.downline = [$scope.downline[0]];
      dCount = 0;
      $scope.dQueue = [];
      fetchDownline(user);
    };

    function fetchDownline(user) {
      user.upline = spliceUpline(user);
      fetchUser(user, 0);
      $scope.jumping = true;
      $scope.downline[0].selected = user.upline[1];

      if (dCount + 2 === user.upline.length) return populateDownline(user);
      User.downline(user.upline[dCount+1], {sort: $scope.sort.type})
      .then(function(items) {
        dCount += 1;
        items = initDownline(items);
        $scope.activeTab = 'team';
        $scope.dQueue.push(items.entities);
        fetchDownline(user);
      });
    }

    function spliceUpline(user) {
      var index = user.upline.indexOf($scope.currentUser.id);
      return user.upline.slice(index, user.upline.length);
    }

    function populateDownline(user) {
      for(var i = 0; i < $scope.dQueue.length; i++) {
        $scope.downline.push($scope.dQueue[i]);
        $scope.downline[i].selected = user.upline[i+1];
        $scope.downline[i].tab = 'team';
      }
      //Sets the last user's tab to info
      $scope.onEnd(0);
      var length = user.upline[user.upline.length - 1];
      $scope.downline[$scope.downline.length - 1].selected = length;
      $scope.activeTab = 'info';
      $scope.downline[dCount].tab = 'info';
      return;
    }

//SORT
    $scope.sort.type = 'team_count';

    $scope.teamSection.sort = function() {
      closeTabs($('#carousel-0'));
      $scope.downline = [];
      for (var i = 0; i < $scope.downline.length; i++){
        destroyCarousel('#carousel-'+ i);
      }

      User.downline($rootScope.currentUser.id, {sort: $scope.sort.type})
      .then(function(items) {
        initDownline(items);
        $scope.downline = [items.entities];
        $timeout(function() {
          initCarousel($('#carousel-0'));
        });
      });
    };

//PROPOSALS
    $scope.teamSection.fetchLeads = function(member) {
      // Clear Sort and Filters when Switching Team Member
      $scope.teamSection.clearFilters();
      $scope.teamSection.leadSearch = '';

      $scope.teamId = member.id;
      CommonService.execute({
        href: '/u/users/' + member.id + '/leads.json'
      }).then(function(items){
        $scope.teamLeads = items.entities;
        destroyCarousel('#teamLeads');
        $timeout(function(){
          initCarousel($('#teamLeads'));
        });
      });
    };

    $scope.teamSection.showLead = function(lead) {
      if (!lead || $scope.leadId === lead.properties.id) {
        $scope.leadId = '';
        $scope.showProposal = false;
        return;
      }
      $scope.showProposal = true;
      $scope.leadId = lead.properties.id;

      CommonService.execute({
        href: '/u/leads/' + lead.properties.id + '.json'
      }).then(function(item){
        $scope.updates = item.entities;
        $scope.activeLead = item;
      });
    };

    // Search / Filter

    $scope.teamSection.searchLeads = function () {
      // Clear Sort and Filters when Searching
      $scope.teamSection.clearFilters();

      $scope.teamSection.applyIndexActions();
    };

    // Clear Sort and Filters
    $scope.teamSection.clearFilters = function() {
      $scope.teamSection.leadSubmittedStatus = '';
      $scope.teamSection.leadDataStatus = '';
      $scope.teamSection.leadSalesStatus = '';
    };

    $scope.teamSection.applyIndexActions = function() {

      /*
      Switch statement to clear leadDataStatus or leadSalesStatus
      from the query when user changes leadSubmittedStatus value:
      */
      switch ($scope.teamSection.leadSubmittedStatus) {
        case 'not_submitted':
          $scope.teamSection.leadSalesStatus = '';
          break;
        case 'submitted':
          $scope.teamSection.leadDataStatus = '';
          break;
        case '':
          $scope.teamSection.leadDataStatus = '';
          $scope.teamSection.leadSalesStatus = '';
          break;
      }

      var data = {
        submitted_status: $scope.teamSection.leadSubmittedStatus,
        data_status: $scope.teamSection.leadDataStatus,
        sales_status: $scope.teamSection.leadSalesStatus
      };

      if ($scope.teamSection.leadSearch) {
        data.search = $scope.teamSection.leadSearch;
      }

      var href = '/u/users/' + $scope.teamId + '/leads';
      closeTabs();
      destroyCarousel('#teamLeads');

      $http({
        method: 'GET',
        url: href,
        params: data,
      }).success(function(items) {
        $scope.teamLeads = items.entities;
        $timeout(function() {
          initCarousel($('#teamLeads'));
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

    // function fetchInvites() {
    //   CommonService.execute({href: '/u/invites.json'}).then(function(data){
    //     $scope.invites = data.entities;
    //     $scope.invites.available = data.properties.available_count;
    //     $scope.invites.redeemed = data.properties.accepted_count;
    //     $scope.inviteFormAction = getAction(data.actions, 'create');
    //     $scope.noInvitesAvailable = false;
    //     if (!$scope.invites.available) {
    //       $scope.noInvitesAvailable = true;
    //     }
    //     destroyCarousel('#invites');
    //     $timeout(function(){
    //       initCarousel($('#invites'));
    //     });
    //   });
    // }

    $scope.sendNewInvite = function() {
      if ($scope.newInviteFields) {
        CommonService.execute($scope.inviteFormAction, $scope.newInviteFields)
        .then(function success(data){
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
      CommonService.execute(resendAction).then(function() {
        fetchInvites();
        closeTabs();
      });
    };

    /*global confirm */
    $scope.deleteInvite = function(invite) {
      var deleteAction = getAction(invite.actions, 'delete');
      if (confirm('Are you sure you want to cancel ' +
                   invite.properties.first_name + ' ' +
                   invite.properties.last_name + '\'s invite?')) {
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

//PLACEMENT
  $scope.placeMode = function(){
    if ($scope.placement.on) $scope.clearPlacement();
    $scope.placement.child = $scope.activeUser;
    $scope.placement.on = true;
    closeAllTabs();
    $timeout(function(){
      $('html, body').animate({
        scrollTop: $('.placement-box').offset().top - $(window).height() + 100
      }, 300);
    });
  };

  $scope.clearPlacement = function() {
    $scope.placement = {};
  };

  $scope.setParent = function(member) {
    if (!$scope.placement.on || !$scope.is.unrelated(member, true)) return;
    $scope.placement.parent = member;
    $timeout(function(){
      $('html, body').animate({
        scrollTop: $('.placement-box').offset().top - $(window).height() + 170
      }, 300);
    });
  };

  $scope.placeUser = function() {
    var obj = $scope.placement;
    CommonService.execute({
      method: 'POST',
      href: '/u/users/' + obj.child.id + '/move.json?parent_id=' + obj.parent.id
    }).then(function(){
      closeAllTabs();
      $scope.clearPlacement();
      immediateDownline();
    });
  };

  $scope.expirationDate = function(member) {
    var startDate = new Date(member.created_at);
    var betaStart = new Date('Mon Jul 30 2015 10:41:08 GMT-0700 (PDT)');
    if (startDate < betaStart) startDate = betaStart;
    startDate = startDate.addDays(60);
    return (startDate.getMonth() + 1) + '/' +
           startDate.getDate() + '/' +
           startDate.getFullYear();
  };

//ON PAGE LOAD
    var level;
    // Fetch User's Immediate downline
    $rootScope.$watch('currentUser', function(data) {
      if (!data || !data.id) return;
      immediateDownline(data);
    });

    // $timeout(function() {
    //   fetchInvites();
    // });

    function immediateDownline(data){
      if (!data) data = $scope.currentUser;
      return User.downline(data.id, {sort: $scope.sort.type})
      .then(function(items) {
        items = initDownline(items);
        destroyCarousel('#carousel-0');
        $scope.downline[0] = items.entities;
        $timeout(function() {
          initCarousel($('#carousel-0'));
          level = $scope.currentUser.level;
        });
      });
    }
  }

  DashboardTeamCtrl.$inject = ['$rootScope', '$scope', '$timeout', '$interval',
                               '$http', '$location', 'User', 'CommonService'];
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
