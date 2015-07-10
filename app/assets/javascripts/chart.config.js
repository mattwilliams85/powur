function chartConfig(scale){  
  'use strict';

    var current = new Date();

    var tabData = {
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
            tooltipXPadding: 12,
            showXLabels: 7,
            multiTooltipTemplate: function(valuesObject){
              if (scale > 30) return formatGroupLabel(valuesObject);
              return formatLabel(valuesObject);
            },
            scaleLabel : function (label) {
                if (label.value === '0') return '';
                return ' ' + label.value;
            },
            scaleOverride: true,
            // ** Required if scaleOverride is true **
            scaleSteps: 5,
            scaleStepWidth: 5
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
            scaleFontSize: 14,
            tooltipXPadding: 12,
            scaleGridLineColor: 'rgba(255,255,255,.15)',
            scaleLineColor: 'rgba(255,255,255,.15)',
            scaleShowVerticalLines: false,
            tooltipTemplate: function(valuesObject){
              if (scale > 30) return formatGroupLabel(valuesObject);
              return formatLabel(valuesObject);
            },
            scaleLabel : function (label) {
                if (label.value === '0') return '';
                return ' ' + label.value;
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
           scaleFontSize: 14,
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

    function formatLabel(l) {
      var slash = l.label.indexOf(' ');
      var label = formatDate(l, slash);

      if(parseInt(l.label) > 0) l.label = label
      if (l.value === 1) return l.value + ' ' + l.datasetLabel;
      return l.value + ' ' + l.datasetLabel + 's';
    }

    function formatGroupLabel(l) {
      if (l.label.length < 7) {
        var date = new Date(l.label + ' ' + current.getFullYear())
        l.label = l.label + ' - ' + $.datepicker.formatDate('M', date.addDays(14)) + ' ' + date.addDays(14).getDate();
      }
      if (l.value === 1) return l.value + ' ' + l.datasetLabel;
      return l.value + ' ' + l.datasetLabel + 's';
    }

    function formatDate(l, slash) {
      var date = l.label.substring(slash + 1, l.label.length);
      if (date.length > 2) return;
      if (date.slice(-2) > 9 && date.slice(-2) < 21) {
        return l.label += 'th'
      } else if (date.slice(-1) == 1) {
        return l.label += 'st';
      } else if (date.slice(-1) == 2) {
        return l.label += 'nd'
      } else if (date.slice(-1) == 3) {
        return l.label += 'rd'
      } else {
        return l.label += 'th'
      }
    }
    return tabData;
};