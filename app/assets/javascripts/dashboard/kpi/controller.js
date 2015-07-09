;(function() {
  'use strict';

  function DashboardKPICtrl($scope, $location, $timeout, UserProfile, CommonService, Utility) {
    $scope.tabData = {
      enviroment: [],
      proposals: {
        settings: [{
          type: 'bar',
          labels: [],
          datasets: [{
            label: "Proposal",
            fillColor: 'rgba(32, 194, 241,.9)',
            highlightFill: '#5bd7f7',
            strokeColor: 'rgba(32, 194, 241,.9)',
            data: []
          },{
            label: "Rooftop",
            fillColor: '#FFC870',
            highlightFill: '#FFC870',
            strokeColor: 'rgba(253, 180, 92, 1)',
            data: []
          }]
        },{
          options: {
            scaleGridLineColor: 'rgba(255,255,255,.15)',
            scaleLineColor: 'rgba(255,255,255,.15)',
            scaleFontColor: '#fff',
            scaleShowVerticalLines: false,
            scaleFontSize: 14,
            barValueSpacing: 3,
            barStrokeWidth : 2,
            barDatasetSpacing: 0,
            scaleStartValue: 0,
            // 
            
            showXLabels: 7,
            multiTooltipTemplate: function(valuesObject){
              if ($scope.scale > 30) return formatGroupLabel(valuesObject);
              return formatLabel(valuesObject);
            },
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
          type: 'line',
          labels: [],
          datasets: [{
            label: 'Advocate',
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
            pointHitDetectionRadius : 1,
            responsive: true,
            scaleFontColor: '#fff',
            scaleFontSize: 13,
            scaleGridLineColor: 'rgba(255,255,255,.15)',
            scaleLineColor: 'rgba(255,255,255,.15)',
            scaleShowVerticalLines: false,
            tooltipTemplate: function(valuesObject){
              if ($scope.scale > 30) return formatGroupLabel(valuesObject);
              return formatLabel(valuesObject);
            },
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

    $scope.scaleOptions = [{
        value: 6, label: 'Last Week'
    }, {
        value: 29, label: 'Last Month'
    }, {
        value: 83, label: 'Last 3 Months'
    }, {
        value: 162, label: 'Last 6 Months'
    }];  


    $scope.scale = 29;
    $scope.current = new Date();
    $scope.legacyImagePaths = legacyImagePaths;

    function formatLabel(l) {
      var months = ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
      var slash = l.label.indexOf('/');
      var date = formatDate(l, slash);
      if(parseInt(l.label) > 0) l.label = months[l.label.substring(0, slash)] + ' ' + date
      // if (l.value === 1) return l.value + ' ' + l.datasetLabel;
      return l.value + ' ' + l.datasetLabel + 's';
    }

    function formatGroupLabel(l) {
      if (l.label.length < 7) {
        var date = new Date(l.label + ' ' + $scope.current.getFullYear())
        l.label = l.label + ' - ' + $.datepicker.formatDate('M', date.addDays(14)) + ' ' + date.addDays(14).getDate();
      }
      if (l.value === 1) return l.value + ' ' + l.datasetLabel;
      return l.value + ' ' + l.datasetLabel + 's';
    }

    function formatDate(l, slash) {
      var str = l.label.substring(slash + 1, l.label.length);
      if (str.slice(-1) == 1) {
        return str += 'st';
      } else if (str.slice(-1) == 2) {
        return str += 'nd'
      } else if (str.slice(-1) == 3) {
        return str += 'rd'
      } else {
        return str += 'th'
      }
    }

    $scope.changeTab = function(section) {
      if ($scope.section === section) return $scope.section = false;

      $scope.scale = 29;
      $scope.active = false;
      $scope.section = section;
      $scope.settings = $scope.tabData[$scope.section].settings;

      $scope.clearData();
      $scope.populateContributors();
    };

    $scope.clearData = function() {
      $scope.team = null;
      $scope.page = 1;
      $scope.position = 0;
      for (var i = 0; i < $scope.settings[0].datasets.length; i++) {
        $scope.settings[0].datasets[i].data = [];
      }
    }

    $scope.scaleFontSize = function(string) {
      if (typeof string !== "string" && typeof string !== "number") return;
      string = string.toString();
      return Math.ceil(1000 / (Math.pow(string.length + 10, 1.2))) + 'pt';
    };

    $scope.buildChart = function() {
      if ($scope.kpiChart) $scope.kpiChart.destroy();

      $scope.populateData();
      $scope.generateLabels();
      $scope.setScale();

      var ctx = document.getElementById('metricsChart').getContext('2d');
      var type = $scope.settings[0].type;

      $scope.settings[1].options.showXLabels = 15;
      if ($scope.scale === 83) $scope.settings[1].options.showXLabels = 6;

      if (type === 'line') {
        $scope.kpiChart = new Chart(ctx).Line($scope.settings[0], $scope.settings[1].options);
      } else {
        $scope.kpiChart = new Chart(ctx).Bar($scope.settings[0], $scope.settings[1].options);
      }
    };

    $scope.setScale = function() {
      //Find largest data point
      var allData = [];
      for (var i = 0; i < $scope.settings[0].datasets.length; i ++) {
        allData = allData.concat($scope.settings[0].datasets[i].data);
      }
      var max = Math.max.apply(Math, allData);

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

      for (var i = 0; i < $scope.settings[0].datasets[0].data.length; i++) {
        if ($scope.scale >= 83) {
          _labels.push($.datepicker.formatDate('M', current.addDays(i*7)) + ' ' + (current.addDays(i*7).getDate()));
        } else {
          _labels.push($.datepicker.formatDate('M', current.addDays(i)) + ' ' + (current.addDays(i).getDate()));
        }
      }
      $scope.settings[0].labels = _labels;
    }

    $scope.changeScale = function(scale) {
      $scope.scale = scale;

      CommonService.execute({href: '/u/kpi_metrics/' + $scope.activeUser.id + '/' + $scope.section + '_show.json?scale=' + $scope.scale}).then(function(data){
        $scope.activeUser = data.properties;
        $scope.buildChart();
      });

    };

    $scope.changeUser = function(user) {
      if ($scope.activeUser === user) return;

      CommonService.execute({href: '/u/kpi_metrics/' + user.id + '/' + $scope.section + '_show.json?scale=' + $scope.scale}).then(function(data){
        $scope.activeUser = data.properties;
        $scope.buildChart();
      });
    };

    $scope.populateContributors = function() {
      //Defaults to Current User
      CommonService.execute({href: '/u/kpi_metrics/' + $scope.currentUser.id + '/' + $scope.section + '_show.json?scale=' + $scope.scale}).then(function(data){
        $scope.activeUser = data.properties;
        $scope.user = $scope.activeUser;
        $scope.user.defaultAvatarThumb = randomThumb();
        $scope.buildChart();
      });
      $scope.populateTeamList();
    };

    function sameDayAs(item, i) {
      return new Date(item.created_at).getMonth() === $scope.current.subDays($scope.scale - i).getMonth() &&
             new Date(item.created_at).getDate() === $scope.current.subDays($scope.scale - i).getDate()
    }

    function searchObjBranch(obj, user_id) {
      if (obj.id === user_id) { return obj; }
      obj = obj['children']
      for(var i in obj) {
        if(obj.hasOwnProperty(i)){
          var returnVal = searchObjBranch(obj[i], user_id);
          if(returnVal) { return returnVal; }
        }
      }
      return null;
    }

    function dataCount(j) {
      var data = angular.copy($scope.activeUser.metrics['data'+j]);
      var count = 0;

      //For each date
      for (var i = 0; i <= $scope.scale; i++) {
        if($scope.section !== "genealogy") count = 0; //Non-incremental
        //For each data item
        for (var n = 0; n < data.length; n++) {
          if (sameDayAs(data[n], i)) {
            data.splice(data.indexOf(data[n]), 1);
            n--; //decrement
            count += 1;
          }
        }
        $scope.settings[0].datasets[j].data.push(count);
      }
    }

    $scope.populateData = function() {
      if (!$scope.activeUser.metrics) return;
      //For each data set
      for (var j = 0; j < $scope.settings[0].datasets.length; j++) {
        $scope.settings[0].datasets[j].data = [];

        dataCount(j);
        if ($scope.scale > 29) clumpData(j);
      }
    };

    function clumpData(j){
      var newData = [];
      var data = $scope.settings[0].datasets[j].data;

      for(var i = 0; i < data.length; i+=7) {
        newData[i/7] = 0;
        for(var n = 0; n < 7; n++) {
          newData[i/7] += (data[i + n] || 0)
        }
        if($scope.section === "genealogy") newData[i/7] = data[i];
      }
     $scope.settings[0].datasets[j].data = newData;
     console.log(newData.length)
    }

    $scope.page = 1;
    $scope.position = 0;

    $scope.changePage = function(direction) {
      if (direction === 'next') {
        if ($scope.page === $scope.max_page) return;
        $scope.page += 1;
        $scope.populateTeamList();
        $scope.position -= 276;
      } else {
        if ($scope.page === 1) return;
        $scope.page -= 1;
        $scope.position += 276;
      }
      //Animate contributors side-bar
     $('.animate-box').velocity({
        translateY: $scope.position + 'px',
      }, {
        duration: 750,
        easing: 'easeOutExpo'
      });
    };

    $scope.populateTeamList = function(){
      CommonService.execute({href: '/u/kpi_metrics/' + $scope.currentUser.id + '/' + $scope.section + '_index.json?page=' + $scope.page}).then(function(data){
        $scope.max_page = data.max_page;
        for (var i = 0; i < data.entities.length; i++){
          data.entities[i].properties.defaultAvatarThumb = randomThumb();
        }
        if($scope.team) return $scope.team = $scope.team.concat(data.entities);
        $scope.team = data.entities;
        $scope.active = true;
      });
    }

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
    //

    $scope.redirectUnlessSignedIn();
  }

  DashboardKPICtrl.$inject = ['$scope', '$location', '$timeout', 'UserProfile', 'CommonService', 'Utility'];
  angular.module('powurApp').controller('DashboardKPICtrl', DashboardKPICtrl)
})();
