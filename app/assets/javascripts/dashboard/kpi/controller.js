;(function() {
  'use strict';
  /*global chartConfig, Chart, randomThumb */

  function DashboardKPICtrl($scope, $location, $timeout, 
                            UserProfile, CommonService) {
    $scope.scaleOptions = [
      { value: 6, label: 'Last 7 Days' }, 
      { value: 29, label: 'Last 30 Days' }, 
      { value: 89, label: 'Last 3 Months' }, 
      { value: 179, label: 'Last 6 Months' }
    ];  
    $scope.userGroup = 'grid';

    $scope.scale = 29;
    $scope.current = new Date();
    $scope.filtered = [];
    $scope.legacyImagePaths = legacyImagePaths;


    $scope.changeTab = function(section) {
      if ($scope.section === section) {
        $scope.section = false;
        return;
      }
      if (section === 'proposals') {
        $scope.sortType = 'lead_count';
      } else {
        $scope.sortType = 'team_count';
      }
      $scope.scale = 29;
      $scope.active = false;
      $scope.section = section;
      $scope.userGroup = 'grid';
      //Refer to chart.config.js for settings/options
      $scope.settings = chartConfig()[$scope.section].settings;

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
    };

    $scope.scaleFontSize = function(string) {
      if (typeof string !== 'string' && typeof string !== 'number') return;
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
      if ($scope.scale > 7) $scope.settings[1].options.showXLabels = 8;

      if (type === 'line') {
        $scope.kpiChart = new Chart(ctx)
          .Line($scope.settings[0], $scope.settings[1].options);
      } else {
        $scope.kpiChart = new Chart(ctx)
          .Bar($scope.settings[0], $scope.settings[1].options);
        greyZeroes();
      }
      spliceFiltered();
      $scope.chartReloading = false;
    };

    $scope.toggleFilter = function(e) {
      var id = e.target.id;
      if($scope.isFiltered(id)) {
        $scope.filtered.splice($scope.filtered.indexOf(id),1);
      } else {
        if ($scope.filtered.length === 4) return; //Filter Limit
        $scope.filtered.push(id);
      }
      $scope.buildChart();
    };

    $scope.isFiltered = function(label) {
      if ($scope.filtered.indexOf(label) > -1) return true;
    };

    function spliceFiltered() {
      for(var i = 0; i < $scope.kpiChart.datasets.length; i++) {
        var type = $scope.kpiChart.datasets[i].label;
        if($scope.isFiltered(type)) {
          $scope.kpiChart.datasets.splice(i, 1);
          i--;
        }
      }
    }

    function greyZeroes() {
      for (var i = 0; i < $scope.kpiChart.datasets.length; i++) {
        for (var j = 0; j < $scope.kpiChart.datasets[i].bars.length; j++) {
          if ($scope.kpiChart.datasets[i].bars[j].value === 0) {
            $scope.kpiChart.datasets[i].bars[j].fillColor = '#aaa';
            $scope.kpiChart.datasets[i].bars[j].strokeColor = '#aaa';
            $scope.kpiChart.datasets[i].bars[j].highlightFill = '#aaa';
          }
        }
      }
      $scope.kpiChart.update();
    }

    $scope.setScale = function() {
      //Find largest data point
      var allData = [];
      for (var i = 0; i < $scope.settings[0].datasets.length; i ++) {
        if ($scope.isFiltered($scope.settings[0].datasets[i].label)) continue;
        allData = allData.concat($scope.settings[0].datasets[i].data);
      }
      var max = Math.max.apply(Math, allData);
      var opt = $scope.settings[1].options;

      //Set Scale
      if (!max) {
        opt.scaleStepWidth = 1;
        opt.scaleSteps = 5;
      } else {
        opt.scaleStepWidth = Math.ceil((max * 1.2) / 12);
        opt.scaleSteps = (max + (max / 2)) / opt.scaleStepWidth;
        if(opt.scaleSteps < 3) opt.scaleSteps = 3;
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
    }; 

    $scope.changeUser = function(user) {
      if ($scope.activeUser === user) return;
      $scope.activeUser = user;
      resetChart();
    }; 

    $scope.changeScale = function(scale) {
      $scope.scale = scale;
      $scope.settings = chartConfig(scale)[$scope.section].settings;

      resetChart();
    };

    $scope.changeGroup = function(group) {
      $scope.userGroup = group;
      resetChart();
    };

    function resetChart() {
      $scope.chartReloading = true;
      if ($scope.userGroup === 'personal') {
        CommonService.execute({href: '/u/kpi_metrics/' + $scope.activeUser.id + '/' + $scope.section + '_show.json?scale=' + $scope.scale}).then(function(data){
          $scope.activeUser = data.properties;
          $scope.buildChart();
        });
      } else {
        CommonService.execute({href: '/u/kpi_metrics/' + $scope.activeUser.id + '/' + $scope.section + '_show_team.json?scale=' + $scope.scale}).then(function(data){
          $scope.activeUser = data.properties;
          $scope.buildChart();
        });
      }
    }

    $scope.populateContributors = function() {
      //Defaults to Current User
      CommonService.execute({href: '/u/kpi_metrics/' + $scope.currentUser.id + '/' + $scope.section + '_show_team.json?scale=' + $scope.scale}).then(function(data){
        
        $scope.activeUser = data.properties;
        $scope.user = $scope.activeUser;
        $scope.user.defaultAvatarThumb = randomThumb();
        $scope.buildChart();
      });
      $scope.populateTeamList();
    };

    function sameDayAs(item, i, j) {
      var attr = $scope.settings[0].datasets[j].filter || 'created_at';
      
      return new Date(item[attr]).getMonth() === $scope.current.subDays($scope.scale - i).getMonth() &&
             new Date(item[attr]).getDate() === $scope.current.subDays($scope.scale - i).getDate();
    }

    function dataCount(j) {
      var data = angular.copy($scope.activeUser.metrics['data'+j]);
      var count = 0;

      //For each date
      for (var i = 0; i <= $scope.scale; i++) {
        if($scope.section !== 'genealogy') count = 0; //Non-incremental
        //For each data item
        for (var n = 0; n < data.length; n++) {
          if (sameDayAs(data[n], i, j)) {
            data.splice(data.indexOf(data[n]), 1);
            n--; //decrement
            count += 1;
          }
        }
        $scope.settings[0].datasets[j].data.push(count);
      }
    }

    $scope.countTotals = function(i) {
      var dataSet = $scope.settings[0].datasets[i].data;
      var count = 0;
      if ($scope.section === 'genealogy') {
        return dataSet[dataSet.length -1] - dataSet[0];
      }
      for(var d = 0; d < dataSet.length; d++) {
        count += dataSet[d];
      }
      return count;
    }

    $scope.populateData = function() {
      if (!$scope.activeUser.metrics) return;
      //For each data set
      var dataLength = Object.keys($scope.activeUser.metrics).length
      for (var j = 0; j < dataLength; j++) {
        $scope.settings[0].datasets[j].data = [];

        dataCount(j);
        if ($scope.scale > 29) clumpData(j);
      }
    };

    function clumpData(j){
      var newData = [];
      var data = $scope.settings[0].datasets[j].data;
      for(var i = 0; i < data.length; i+=7) {
        if($scope.section === 'genealogy') {
          newData[i/7] = data[i - 1] || 0;

          for(var n = 0; n < 7; n++) {
            if(data[i + n] > newData[i/7]) newData[i/7] = data[i + n]
          }
        } else {
          newData[i/7] = 0;

          for(var n = 0; n < 7; n++) {
            newData[i/7] += (data[i + n] || 0);
          }
        }
      }
     $scope.settings[0].datasets[j].data = newData;
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
      CommonService.execute({
        href: '/u/users/' + $scope.currentUser.id + '/full_downline.json?',
        params: {
          sort: $scope.sortType,
          item_totals: $scope.sortType,
          page: $scope.page,
          user_totals: true,
          limit: 8
        }
      }).then(function(data){
        $scope.max_page = Math.ceil(data.properties.paging.item_count / 4);
        for (var i = 0; i < data.entities.length; i++){
          data.entities[i].properties.defaultAvatarThumb = randomThumb();
        }
        if($scope.team) return $scope.team = $scope.team.concat(data.entities);
        $scope.team = data.entities;
        $scope.active = true;
      });
    };

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

  DashboardKPICtrl.$inject = ['$scope', '$location', '$timeout', 'UserProfile', 'CommonService'];
  angular.module('powurApp').controller('DashboardKPICtrl', DashboardKPICtrl)
})();
