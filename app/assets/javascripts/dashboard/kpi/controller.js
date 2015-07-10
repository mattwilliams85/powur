;(function() {
  'use strict';

  function DashboardKPICtrl($scope, $location, $timeout, UserProfile, CommonService, Utility) {
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


    $scope.changeTab = function(section) {
      if ($scope.section === section) return $scope.section = false;

      $scope.scale = 29;
      $scope.active = false;
      $scope.section = section;
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
      $scope.settings = chartConfig(scale)[$scope.section].settings;

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
      var attr = 'created_at'
      if (item.contract) attr = 'contract'
      return new Date(item[attr]).getMonth() === $scope.current.subDays($scope.scale - i).getMonth() &&
             new Date(item[attr]).getDate() === $scope.current.subDays($scope.scale - i).getDate()
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
