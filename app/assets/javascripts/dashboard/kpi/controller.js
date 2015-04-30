;(function() {
  'use strict';

  function DashboardKPICtrl($scope, $location, $timeout, UserProfile) {
    $scope.tabData = {
      enviroment: [],
      conversion: {
        settings: [{
          labels: [],
          datasets: [{
            fillColor: "rgba(32, 194, 241,.85)",
            highlightFill: "#5bd7f7",
            strokeColor: "rgba(220,220,220,1)",
            pointColor: "rgba(32, 194, 241,.9)",
            data: []
          },{
            fillColor: "rgba(253, 180, 92, .85)",
            highlightFill: "#FFC870",
            strokeColor: "rgba(220,220,220,1)",
            pointColor: "rgba(253, 180, 92, .9)",
            data: []
          }]
        },{
          options: {
            scaleGridLineColor: "rgba(255,255,255,.15)",
            scaleLineColor: "rgba(255,255,255,.15)",
            scaleFontColor: "#fff",
            barShowStroke: true,
            barStrokeWidth: 2,
            barValueSpacing: 20,
            barDatasetSpacing: 1,
            scaleFontSize: 13,
            scaleOverride: true,
            scaleSteps: 12,
            scaleStepWidth: 12,
            scaleStartValue: 0
          }
        }]
      },
      genealogy: {
        settings: [{
          labels: [],
          datasets: [{
            label: "My First dataset",
            fillColor: "rgba(32, 194, 241,.9)",
            highlightFill: "#5bd7f7",
            strokeColor: "rgba(32, 194, 241,.9)",
            data: []
          }]
        },{
          options: {
            scaleGridLineColor: "rgba(255,255,255,.15)",
            scaleLineColor: "rgba(255,255,255,.15)",
            scaleFontColor: "#fff",
            bezierCurveTension: .3,
            pointDotRadius: 4,
            scaleFontSize: 13,
            scaleOverride: true,
            // ** Required if scaleOverride is true **
            scaleSteps: 12,
            scaleStepWidth: 12,
            scaleStartValue: 0,
            barValueSpacing: 3,
          }
        }]
      },
      earnings: {
        settings: [{
          labels: [],
          datasets: [{
            label: "My dataset",
            fillColor: "rgba(220,220,0,0)",
            strokeColor: "rgba(32,194,241,1)",
            pointColor: "rgba(32,194,241,1)",
            pointStrokeColor: "#fff",
            pointHighlightFill: "#fff",
            pointHighlightStroke: "rgba(220,220,220,1)",
            data: []
          }]
        },{
          options: {
           scaleGridLineColor: "rgba(255,255,255,.15)",
           scaleLineColor: "rgba(255,255,255,.15)",
           scaleFontColor: "#fff",
           barShowStroke: true,
           bezierCurveTension: .2,
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

    $scope.scale = 'week';
    $scope.current = new Date();
    $scope.date = 'week ' + $scope.current.getWeek();
    // $scope.tabKey = 'conversion';
    // $scope.settings = $scope.tabData[$scope.tabKey].settings;
    $scope.page = 1;
    $scope.position = 0;


    $scope.changeTab = function(section) {
      // angular.element('.kpi-drilldown').css('height','0')
      if ($scope.section === section) return $scope.closeTab();
      $scope.section = section;
      $scope.tabKey = '';
      $timeout( function(){ 
        $scope.tabKey = section
        $scope.settings = $scope.tabData[$scope.tabKey].settings;
        $scope.kpiInit();
      }, 300);
    }

    $scope.closeTab = function(section) {
      $scope.section = '';
      $scope.tabKey = '';
    }

    // $scope.createTabUrl = function(section) {
    //   return "dashboard/templates/sections/kpi/metrics/" + section + ".html";
    // };

    //FOR GENE
    // function randomizeData(length) {
    //   metricsData.datasets[0].data = []
    //   total = 10;
    //   for (i = 0; i <= length; i++) {
    //     metricsData.datasets[0].data.push(total += Math.floor(Math.random() * 2));
    //   }
    // }

    $scope.kpiInit = function() {
      if($scope.kpiChart) $scope.kpiChart.destroy();
      $scope.randomizeData();
      $scope.setScale();
      $scope.populateContributors();
      $scope.setCalendar();
      $scope.ctx = document.getElementById("metricsChart").getContext("2d");
      if(window.innerWidth < 500) {
        $scope.ctx.canvas.width = 300;
        $scope.ctx.canvas.height = 300;
      } else {
        $scope.ctx.canvas.height = 330;
        $scope.ctx.canvas.width = 650;
      }
      $scope.kpiChart = new Chart($scope.ctx).Line($scope.settings[0], $scope.settings[1].options);
    }

    $scope.scaleFontSize = function(string) {
      return Math.ceil(1000 / (Math.pow(string.length + 10, 1.2))) + 'pt';
    }

    $scope.rebuildChart = function() {
      $scope.kpiChart.destroy();
      $scope.randomizeData();
      $scope.setScale();
      //TEMP - Change this to be dynamic based on container width!
      // debugger
      $scope.ctx.canvas.height = 330;
      $scope.ctx.canvas.width = 650;
      //
      $scope.kpiChart = new Chart($scope.ctx).Line($scope.settings[0], $scope.settings[1].options);
    }

    $scope.setScale = function() {
      var _labels = [];

      if ($scope.scale == "week") {
        for (var i = 0; i <= 6; i++) {
          _labels.push($scope.current.addDays(i).getMonth() + 1 + "/" + ($scope.current.addDays(i).getDate()));
        }
      } else {
        $scope.current.setDate(1);
        for (var i = 0; i <= $scope.daysInMonth() - 1; i++) {
          _labels.push($scope.current.addDays(i).getMonth() + 1 + "/" + ($scope.current.getDate() + i));
        }
      }
      $scope.settings[1].options.scaleStepWidth = Math.ceil((Math.max.apply(Math, $scope.settings[0].datasets[0].data) * 1.2) / 12);
      $scope.settings[0].labels = _labels;
    }

    $scope.changeScale = function(scale) {
      $scope.scale = scale
      if (scale === 'week') {
        $scope.date = 'week ' + $scope.current.getWeek()
      } else {
        $scope.date = $.datepicker.formatDate('MM', $scope.current) + ' ' + $scope.current.getFullYear();
      }
      $scope.rebuildChart();
    }

    $scope.changeUser = function(user) {
      if ($scope.activeUser == user) return;
      if (user) {
        $scope.activeUser = user;
      } else {
        $scope.activeUser = false;
      }
      $scope.rebuildChart();
    }

    $scope.populateContributors = function() {
      UserProfile.get().then(function(data){
        $scope.user = data;
        UserProfile.getTeam(data.id).then(function(data){
          $scope.team = data.entities;
          console.log($scope.team)
        });
      });
    }

    $scope.changePage = function(direction) {
      if (direction === 'next') {
        if ($scope.team.length / $scope.page <= 4) return;
        $scope.page += 1;
        $scope.position -= 276;
      } else {
        if ($scope.page == 1) return;
        $scope.page -= 1;
        $scope.position += 276;
      };
      //Animate contributors bar
      $('.contributor').each(function() {
        $(this).velocity({
          translateY: $scope.position + "px"
        }, {
          duration: 50,
          easing: "easeOutQuint"
        });
      })
    }


    //TIME FUNCTIONS
    $scope.daysInMonth = function() {
      var days = new Date($scope.current);
      days = new Date(days.setMonth($scope.current.getMonth() + 1));
      return (new Date(days.setDate(0))).getDate();
    }

    $scope.setCalendar = function() {
      if ($scope.scale === "week") {
        var daysFromSun = $scope.current.getDay()
        return new Date($scope.current.setDate($scope.current.getDate() - daysFromSun))
      } else {
        return $scope.current.setDate(1);
      }
    }

    $scope.calendarBack = function() {
      if ($scope.scale === "week") {
        $scope.current = new Date($scope.current.setDate($scope.current.getDate() - 7))
      } else {
        $scope.current = new Date($scope.current.setMonth($scope.current.getMonth() - 1))
      }
     $scope.changeScale($scope.scale);
    }

    $scope.calendarForward = function() {
      if ($scope.scale === "week") {
        $scope.current = new Date($scope.current.setDate($scope.current.getDate() + 7))
      } else {
        $scope.current = new Date($scope.current.setMonth($scope.current.getMonth() + 1))
      }
      $scope.changeScale($scope.scale);
    }

    $scope.setCalendar = function() {
      if($scope.scale === "week") {
        var daysFromSun = $scope.current.getDay()
        return new Date($scope.current.setDate($scope.current.getDate() - daysFromSun))
      } else {
        return $scope.current.setDate(1);
      }
    }
    //*END TIME FUNCTIONS

    //TEMP
    $scope.randomizeData = function() {
      var length = 30;
      if($scope.scale == "week") length = 6;

      $scope.settings[0].datasets[0].data = []
      if ($scope.settings[0].datasets.length < 2) {
        for (var i = 0; i <= length; i++) {
          $scope.settings[0].datasets[0].data.push(Math.floor(Math.random() * 30 + 20));
        }
      } else {
        $scope.settings[0].datasets[1].data = []
        for (var i = 0; i <= length; i++) {
          $scope.settings[0].datasets[0].data.push(Math.floor(Math.random() * 30 + 20));
          $scope.settings[0].datasets[1].data.push(Math.floor(Math.random() * 20 + 15));
        }
      }
    }

    $scope.redirectUnlessSignedIn();
  }

  DashboardKPICtrl.$inject = ['$scope', '$location', '$timeout', 'UserProfile'];
  angular.module('powurApp').controller('DashboardKPICtrl', DashboardKPICtrl)
  // RESIZE DETECTION
  // .directive('resizable', function($window) {
  //   return function($scope) {
  //     $scope.initializeWindowSize = function() {
  //       return $scope.windowWidth = $window.innerWidth;
  //     };
  //     $scope.initializeWindowSize();
  //     return angular.element($window).bind('resize', function() {
  //       $scope.initializeWindowSize();
  //       if($scope.windowWidth < 800) $scope.resizeChart()
  //       return $scope.$apply();
  //     });
  //   };
  // });

})();