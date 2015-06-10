;(function() {
  'use strict';

  function DashboardKPICtrl($scope, $location, $timeout, UserProfile, CommonService, Utility) {
    $scope.tabData = {
      enviroment: [],
      proposals: {
        settings: [{
          type: 'line',
          labels: [],
          datasets: [{
            fillColor: 'rgba(255, 186, 120, 0.2)',
            highlightFill: '#FFC870',
            pointColor: 'rgba(253, 180, 92, 1)',
            pointStrokeColor: 'rgb(68, 68, 68)',
            pointHighlightFill: "#fff",
            pointHighlightStroke: "#444",
            strokeColor: 'rgba(253, 180, 92, 1)',
            data: []
          },{
            fillColor: 'rgba(108, 207, 255, 0.15)',
            highlightFill: '#5bd7f7',
            pointColor: '#20c2f1',
            pointStrokeColor: 'rgb(68, 68, 68)',
            pointHighlightFill: "#fff",
            pointHighlightStroke: "#444",
            strokeColor: '#20c2f1',
            data: []
          }]
        },{
          options: {
            bezierCurve: false,
            maintainAspectRatio: false,
            pointDotStrokeWidth : 2,
            pointHitDetectionRadius : 10,
            responsive: true,
            scaleFontColor: '#fff',
            scaleFontSize: 13,
            scaleGridLineColor: 'rgba(255,255,255,.15)',
            scaleLineColor: 'rgba(255,255,255,.15)',
            scaleShowVerticalLines: false,
            scaleOverride: true,
            // ** Required if scaleOverride is true **
            scaleSteps: 5,
            scaleStepWidth: 5,
            //
            scaleLabel : function (label) {
                if (label.value === '0') return '';
                return label.value;
            }
          }
        }]
      },
      genealogy: {
        settings: [{
          type: 'bar',
          labels: [],
          datasets: [{
            label: 'My First dataset',
            fillColor: 'rgba(32, 194, 241,.9)',
            highlightFill: '#5bd7f7',
            strokeColor: 'rgba(32, 194, 241,.9)',
            data: []
          }]
        },{
          options: {
            scaleGridLineColor: 'rgba(255,255,255,.15)',
            scaleLineColor: 'rgba(255,255,255,.15)',
            scaleFontColor: '#fff',
            scaleShowVerticalLines: false,
            scaleFontSize: 13,
            barValueSpacing: 3,
            scaleStartValue: 0,
            scaleOverride: true,
            // ** Required if scaleOverride is true **
            scaleSteps: 12,
            scaleStepWidth: 12,
          }
        }]
      },
      earnings: {
        settings: [{
          labels: [],
          datasets: [{
            label: 'My dataset',
            fillColor: 'rgba(220,220,0,0)',
            strokeColor: 'rgba(32,194,241,1)',
            pointColor: 'rgba(32,194,241,1)',
            pointStrokeColor: '#fff',
            pointHighlightFill: '#fff',
            pointHighlightStroke: 'rgba(220,220,220,1)',
            data: []
          }]
        },{
          options: {
           scaleGridLineColor: 'rgba(255,255,255,.15)',
           scaleLineColor: 'rgba(255,255,255,.15)',
           scaleFontColor: '#fff',
           barShowStroke: true,
           bezierCurveTension: 0.2,
           barStrokeWidth: 2,
           barValueSpacing: 20,
           barDatasetSpacing: 1,
           scaleFontSize: 13,
           scaleOverride: true,
           // ** Required if scaleOverride is true **
           scaleSteps: 12,
           scaleStepWidth: 12,
           scaleStartValue: 0,
          }
        }]
      },
      rank: []
    };

    $scope.scale = 6;
    $scope.current = new Date();
    $scope.section = '';
    $scope.legacyImagePaths = legacyImagePaths;
    
    $scope.changeTab = function(section) {
      if (!$scope.isTabClickable) return;

      $scope.active = false

      if ($scope.section === section) {
        return  $scope.section = '';
      } else if (section === 'genealogy') {
        $scope.section = section;
        if ($scope.tabData[$scope.section]) $scope.settings = $scope.tabData[$scope.section].settings;
        $scope.kpiInit();
      } else {
        $scope.section = section;
        if ($scope.tabData[$scope.section]) $scope.settings = $scope.tabData[$scope.section].settings;
        $scope.kpiInit();
      }
    };

    $scope.kpiInit = function() {
      $scope.populateContributors();
    };

    $scope.scaleFontSize = function(string) {
      if (!isNaN(string)) {
        string = string.toString();
        return Math.ceil(1000 / (Math.pow(string.length + 10, 1.2))) + 'pt';
      }
    };

    $scope.buildChart = function() {

      if ($scope.kpiChart) $scope.kpiChart.destroy();
      $scope.populateData();
      $scope.generateLabels();
      $scope.setScale();
      var ctx = document.getElementById('metricsChart').getContext('2d');

      var type = $scope.settings[0].type;
      
      if (type === 'line') {
        $scope.kpiChart = new Chart(ctx).Line($scope.settings[0], $scope.settings[1].options);
      } else {
        $scope.kpiChart = new Chart(ctx).Bar($scope.settings[0], $scope.settings[1].options);
      }
    };

    $scope.setScale = function() {
      //Find largest data point
      var bigData = []; 
      for (var i = 0; i < $scope.settings[0].datasets.length; i ++) {
        bigData = bigData.concat($scope.settings[0].datasets[i].data);
      } 
      var max = Math.max.apply(Math, bigData);

      //Set Scale
      if (!max) {
        $scope.settings[1].options.scaleStepWidth = 1;
        $scope.settings[1].options.scaleSteps = 5;
      } else {
        $scope.settings[1].options.scaleStepWidth = Math.ceil((max * 1.2) / 12);
        $scope.settings[1].options.scaleSteps = (max + (max / 2)) / $scope.settings[1].options.scaleStepWidth;
        if($scope.settings[1].options.scaleSteps < 5) $scope.settings[1].options.scaleSteps = 5;
      }
    };

    $scope.generateLabels = function() {
      var _labels = [];
      var current = $scope.current.subDays($scope.scale);

      for (var i = 0; i <= $scope.scale; i++) {
        if ($scope.scale === 6) {
          _labels.push($.datepicker.formatDate('M', current.addDays(i)) + ' ' + (current.addDays(i).getDate()));
        } else {
          _labels.push(current.addDays(i).getMonth() + 1 + '/' + current.addDays(i).getDate());
        }
      }
      $scope.settings[0].labels = _labels;
    }

    $scope.changeScale = function(scale) {
      $scope.scale = scale;
      $scope.buildChart();
    };

    $scope.changeUser = function(user) {
      if ($scope.activeUser === user) return;
      if ($scope.section === 'genealogy') {
        $scope.activeUser = user;
        return $scope.buildChart();
      }
      CommonService.execute({href: '/u/kpi_metrics/' + user.id + '/' + $scope.section + '_show.json'}).then(function(data){
        $scope.activeUser = data.properties;
        $scope.buildChart();
      });
    };

    $scope.populateContributors = function() {
      //Defaults to Current User
      CommonService.execute({href: '/u/kpi_metrics/' + $scope.currentUser.id + '/' + $scope.section + '_show.json'}).then(function(data){
        $scope.user = data.properties;
        $scope.activeUser = $scope.user;
        if ($scope.section === 'genealogy' && !$scope.tree) return genealogyTree();
        $scope.buildChart();
      });
      //Populates Team List
      CommonService.execute({href: '/u/kpi_metrics/' + $scope.currentUser.id + '/' + $scope.section + '_index.json'}).then(function(data){
        $scope.team = data.entities;
        $scope.active = true;
      });
    };

    var searchObjBranch = function(obj, user_id) {
      if (obj.user.id === user_id) { return obj; }
      obj = obj['children']
      for(var i in obj) {
        if(obj.hasOwnProperty(i)){
          var returnVal = searchObjBranch(obj[i], user_id);
          if(returnVal) { return returnVal; }
        }
      }
      return null;
    }

    var proposalCount = function(j) {
      if (!$scope.activeUser.metrics_data) return;
      //For each data point
      for (var i = 0; i <= $scope.scale; i++) {
        var count = 0;
        $.each($scope.activeUser.metrics_data['data'+j], function(key, value){
          if ( new Date(value.created_at).getMonth() === $scope.current.subDays($scope.scale - i).getMonth() &&
              new Date(value.created_at).getDate() === $scope.current.subDays($scope.scale - i).getDate()
            ) {
            count += 1;
          }
        });
        $scope.settings[0].datasets[j].data.push(count);
      }
    }

    var genealogyTree = function() {
      CommonService.execute({href: '/u/kpi_metrics/' + $scope.currentUser.id + '/user_tree.json'}).then(function(data){
        $scope.tree = data.tree;
        $scope.buildChart();
      });
    }

    var countChildren = function(obj, count, i) {
      obj = obj['children']

      for(var key in obj) {
        if(obj.hasOwnProperty(key)){
            if ( new Date(obj[key].user.created_at).getMonth() === $scope.current.subDays($scope.scale - i).getMonth() &&
                new Date(obj[key].user.created_at).getDate() === $scope.current.subDays($scope.scale - i).getDate()
               ) {
            count += 1;
            countChildren(obj[key], count);
          }
        }
      }
      return count;
    }

    var genealogyCount = function(j) {
      if (!$scope.tree) return;
      // debugger
      var branch = searchObjBranch($scope.tree[$scope.currentUser.id], $scope.activeUser.id)
      //For each data point
      var count = 0;
      for (var i = 0; i <= $scope.scale; i++) {
        count = countChildren(branch, count, i)
        $scope.settings[0].datasets[j].data.push(count);
      }
    }

    $scope.populateData = function() {
      //For each data set
      for (var j = 0; j < $scope.settings[0].datasets.length; j++) {
        $scope.settings[0].datasets[j].data = [];

        if ($scope.section === "proposals") {
          proposalCount(j)
        } else if ($scope.section === "genealogy") {
          genealogyCount(j)
        } else {

        }
      }
    };

    $scope.page = 1;
    $scope.position = 0;

    $scope.changePage = function(direction) {
      if (direction === 'next') {
        if ($scope.team.length / $scope.page <= 4) return;
        $scope.page += 1;
        $scope.position -= 276;
      } else {
        if ($scope.page === 1) return;
        $scope.page -= 1;
        $scope.position += 276;
      }
      //Animate contributors bar
      $('.contributor').each(function() {
        $(this).velocity({
          translateY: $scope.position + 'px'
        }, {
          duration: 50,
          easing: 'easeOutQuint'
        });
      });
    };

    // $scope.weeklyGrowth = function(member) {
    //   if (!member) return
    //   if (!member.weekly_growth) return 0;
    //   var growth = member.weekly_growth / member.full_downline_count
    //   if (growth % 1 === 0) return growth;
    //   return growth.toFixed(1);
    // }

    //CALENDAR FUNCTIONS
    $scope.daysInMonth = function() {
      var days = new Date($scope.current);
      days = new Date(days.setMonth($scope.current.getMonth() + 1));
      return (new Date(days.setDate(0))).getDate();
    };

    $scope.setCalendar = function() {
      if ($scope.scale === 6) {
        var daysFromSun = $scope.current.getDay();
        return new Date($scope.current.setDate($scope.current.getDate() - daysFromSun));
      } else {
        return $scope.current.setDate(1);
      }
    };

    $scope.calendarBack = function() {
      if ($scope.scale === 6) {
        $scope.current = new Date($scope.current.setDate($scope.current.getDate() - 7));
      } else {
        $scope.current = new Date($scope.current.setMonth($scope.current.getMonth() - 1));
      }
      $scope.changeScale($scope.scale);
    };

    $scope.calendarForward = function() {
      if ($scope.scale === 6) {
        $scope.current = new Date($scope.current.setDate($scope.current.getDate() + 7));
      } else {
        $scope.current = new Date($scope.current.setMonth($scope.current.getMonth() + 1));
      }
      $scope.changeScale($scope.scale);
    };

    $scope.setCalendar = function() {
      if($scope.scale === 6) {
        var daysFromSun = $scope.current.getDay();
        return new Date($scope.current.setDate($scope.current.getDate() - daysFromSun));
      } else {
        return $scope.current.setDate(1);
      }
    };
    //

    $scope.redirectUnlessSignedIn();
  }

  DashboardKPICtrl.$inject = ['$scope', '$location', '$timeout', 'UserProfile', 'CommonService', 'Utility'];
  angular.module('powurApp').controller('DashboardKPICtrl', DashboardKPICtrl)
})();
