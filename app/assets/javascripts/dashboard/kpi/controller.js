;(function() {
  'use strict';

  function DashboardKPICtrl($scope, $location, $timeout, UserProfile, CommonService) {
    $scope.tabData = {
      enviroment: [],
      conversion: {
        settings: [{
          labels: [],
          datasets: [{
            fillColor: 'rgba(255, 186, 120, 0.2)',
            highlightFill: '#FFC870',
            strokeColor: 'rgba(253, 180, 92, 1)',
            pointColor: 'rgba(253, 180, 92, 1)',
            pointStrokeColor: 'rgb(68, 68, 68)',
            pointHighlightFill: "#fff",
            pointHighlightStroke: "#444",
            data: []
          },{
            fillColor: 'rgba(108, 207, 255, 0.15)',
            highlightFill: '#5bd7f7',
            strokeColor: '#20c2f1',
            pointColor: '#20c2f1',
            pointStrokeColor: 'rgb(68, 68, 68)',
            pointHighlightFill: "#fff",
            pointHighlightStroke: "#444",
            data: []
          }]
        },{
          options: {
            scaleGridLineColor: 'rgba(255,255,255,.15)',
            scaleLineColor: 'rgba(255,255,255,.15)',
            scaleFontColor: '#fff',
            scaleShowVerticalLines: false,
            scaleFontSize: 13,
            bezierCurve: false,
            scaleOverride: true,
            pointDotStrokeWidth : 2,
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
            bezierCurveTension: 0.3,
            pointDotRadius: 4,
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
      // RETURN UNLESS CONVERSION
      if(section !== 'conversion') return;
      //
      if ($scope.section === section) return $scope.section = '';
      $scope.section = section;
      // Timeout for animation
      $timeout(function() {
        $scope.section = section;
        if ($scope.tabData[$scope.section]) $scope.settings = $scope.tabData[$scope.section].settings;
        $scope.kpiInit();
      }, 300);
    };

    $scope.kpiInit = function() {
      $scope.populateContributors();
    };

    $scope.scaleFontSize = function(string) {
      return Math.ceil(1000 / (Math.pow(string.length + 10, 1.2))) + 'pt';
    };

    $scope.buildChart = function() {
      if ($scope.kpiChart) $scope.kpiChart.destroy();
      $scope.populateData();
      $scope.generateLabels();
      $scope.setScale();

      $scope.ctx = document.getElementById('metricsChart').getContext('2d');
      $scope.ctx.canvas.height = $('.chart-box').height();
      $scope.ctx.canvas.width = $('.chart-box').width();
    
      $scope.kpiChart = new Chart($scope.ctx).Line($scope.settings[0], $scope.settings[1].options);
    };

    $scope.setScale = function() {
      //Find largest data point
      var max = Math.max.apply(Math, $scope.settings[0].datasets[0].data.concat($scope.settings[0].datasets[1].data));

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
      CommonService.execute({href: '/u/kpi_metrics/'+ user.id +'/proposals_show.json'}).then(function(data){
        $scope.activeUser = data.properties;
      });
      $scope.buildChart();
    };

    $scope.populateContributors = function() {
      CommonService.execute({href: '/u/kpi_metrics/'+ $scope.currentUser.id +'/proposals_show.json'}).then(function(data){
        $scope.user = data.properties;
        //Defaults to Current User
        $scope.activeUser = $scope.user;
        //
        $scope.buildChart();
        CommonService.execute({href: '/u/kpi_metrics/' +data.properties.id+ '/proposals_index.json'}).then(function(data){
          $scope.team = data.entities;
        });
      });
    };

    $scope.populateData = function() {
      //For each data set
      for (var j = 0; j <= Object.keys($scope.activeUser.metrics_data).length - 1; j++) {
        $scope.settings[0].datasets[j].data = [];

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

    //TIME FUNCTIONS
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

  DashboardKPICtrl.$inject = ['$scope', '$location', '$timeout', 'UserProfile', 'CommonService'];
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
