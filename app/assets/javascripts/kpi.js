var scale = "week";
var _labels = [];
var position = 0;
var page = 1;
var now = setCalendar();
var myChart = ""
var ctx = ""

var metricsData = {
  labels: _labels,
  datasets: [{
    fillColor: "rgba(32, 194, 241,.9)",
    highlightFill: "#5bd7f7",
    strokeColor: "rgba(220,220,220,1)",
    pointColor: "rgba(32, 194, 241,.9)",
    data: []
  }, {
    fillColor: "rgba(253, 180, 92, .9)",
    highlightFill: "#FFC870",
    strokeColor: "rgba(220,220,220,1)",
    pointColor: "rgba(253, 180, 92, .9)",
    data: []
  }]
};

var options = {
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
  // ** end **
  scaleLabel: " <%= !Number(value) ? '' :  Number(value)%>",
  legendTemplate: "<ul class=\"<%=name.toLowerCase()%>-legend\"> \
                     <% for (var i=0; i<datasets.length; i++){%> \
                       <li><span style=\"background-color:<%=datasets[i].lineColor%>\"> \
                         </span><%if(datasets[i].label){%><%=datasets[i].label%><%}%> \
                       </li> \
                     <%}%> \
                   </ul>"
}

function initPage(){
  displayTimeScale()
  randomizeData(6);
  setScale();
  randomizeOrders();
  populateContributors();
  checkPage()
  ctx = $("#metricsChart").get(0).getContext("2d");
  myChart = new Chart(ctx).Line(metricsData, options);
}

function randomizeOrders() {
  _data.team.entities.forEach(function(member) {
    member.properties.orders = Math.floor(Math.random() * 30 + 10)
  });
}

function randomizeData(length) {
  metricsData.datasets[0].data = []
  metricsData.datasets[1].data = []
  for (i = 0; i <= length; i++) {
    metricsData.datasets[0].data.push(Math.floor(Math.random() * 30 + 20));
    metricsData.datasets[1].data.push(Math.floor(Math.random() * 10 + 15));
  }
}

function rebuildChart(scale){
  displayTimeScale()
  myChart.destroy();
  randomizeData(scale)
  setScale()
  ctx.canvas.width = 670
  ctx.canvas.height = 330
  myChart = new Chart(ctx).Line(metricsData, options);
}

function populateContributors() {
  var _contributors = $(".contributors");

  top_ten = _data.team.entities.slice(0, 10)

  top_ten.forEach(function(member) {
    _ajax({
      _ajaxType: "get",
      _url: "/u/users/" + member.properties.id + "/downline",
      _callback: function(data, text) {
        member.properties.downline_count = data.entities.length;
        EyeCueLab.UX.getTemplate("/templates/_kpi_quote_team_thumbnail.handlebars.html", member, undefined, function(html) {
          if ($('.contributor').length == top_ten.length) contributorEvents();
          _contributors.append(html);
        });
      }
    });
  });
}

// ** CALENDAR FUNCTIONS **
function setScale() {
  _labels = [];
  
  if (scale == "week") {
    for (i = 0; i <= 6; i++) {
      _labels.push(now.getMonth() + 1 + "/" + (now.addDays(i).getDate()));
    }
  } else {
    for (i = 0; i <= numberOfDaysInMonth() - 1; i++) {
      _labels.push(now.getMonth() + 1 + "/" + (now.getDate() + i));
    }
  }
  options.scaleStepWidth = Math.ceil((Math.max.apply(Math, metricsData.datasets[0].data) * 1.5) / 12);
  metricsData.labels = _labels
}

function setCalendar() {
  if(scale === "week") {
    now = new Date()
    daysFromSun = now.getDay()
    return new Date(now.setDate(now.getDate() - daysFromSun))
  } 
  if(scale === "month") return now.setDate(1);
}

function numberOfDaysInMonth() {
  days = new Date(now);
  days = new Date(days.setMonth(now.getMonth() + 1));
  return (new Date(days.setDate(0))).getDate();
}

function calendarBack() {
  if(scale === "week") now = new Date(now.setDate(now.getDate() - 7))
  if(scale === "month") now = new Date(now.setMonth(now.getMonth() - 1))
}

function calendarForward() {
  if(scale === "week") now = new Date(now.setDate(now.getDate() + 7))
  if(scale === "month") now = new Date(now.setMonth(now.getMonth() + 1))
}

function displayTimeScale() {
  if(scale === "week") $(".week-span").html("WEEK " + now.getWeek());
  if(scale === "month") $(".week-span").html($.datepicker.formatDate('MM', now));
}
// ** END **

// ** JQUERY EVENTS **
$('.back').on("click", function() {
  calendarBack()
  timeScale = 7;
  if(scale == "month") timeScale = numberOfDaysInMonth() - 1
  rebuildChart(timeScale)
})

$('.forward').on("click", function() {
  calendarForward()
  timeScale = 7;
  if(scale == "month") timeScale = numberOfDaysInMonth() - 1
  rebuildChart(timeScale)
})

$(".return_to_team").on("click", function(e) {
  rebuildChart(numberOfDaysInMonth() - 1)
  $(".graph_title").html("Full Performance History");
  $(".contributor").css("background", "#545454");
  $(".return_to_team").hide();
  $(".progress_description").fadeIn();
});

$(".current").on("click", function(e) {
  now = new Date()
  rebuildChart(30)
})

$(".time_scale .month").on("click", function() {
  scale = "month"
  setCalendar()
  rebuildChart(30)
  $(".time_scale .week").removeClass("active");
  $(this).addClass("active");
})

$(".time_scale .week").on("click", function() {
  scale = "week"
  setCalendar()
  rebuildChart(30)
  $(".time_scale .month").removeClass("active");
  $(this).addClass("active");
})

// ** PAGINATION FOR USERS **
$('.fa-caret-down').on("click", function(e) {
  if ($(this).hasClass("active")) {
      page += 1;
      position -= 406;
      animateContributors()
    };
});

$('.fa-caret-up').on("click", function(e) {
  if ($('.fa-caret-up').hasClass("active")) {
    page -= 1;
    position += 406;
    animateContributors()
  };
});

function animateContributors(){
  checkPage();
  $('.contributor').each(function() {
    $(this).velocity({
      backgroundColor: "#545454"
    }, 100);
  })
  $('.contributor').each(function() {
    $(this).velocity({
      translateY: position + "px"
    });
  })
}

function checkPage() {
  if (page === 1) {
    $('.fa-caret-up').css("opacity", "0.3").removeClass("active");
    $('.fa-caret-down').css("opacity", "1").addClass("active");
  } else {
    $('.fa-caret-up').css("opacity", "1").addClass("active");
    $('.fa-caret-down').css("opacity", "0.3").removeClass("active");
  }
}
// ** END **

// Runs after ajax returns 10 users
function contributorEvents() {
  $(".contributor")
    .show()
    .velocity("transition.slideUpBigIn", {
      stagger: 200,
      duration: 600
    })
  $(".contributor").on("click", function(e) {
    e.preventDefault();
    e.stopPropagation();
    $(".return_to_team").fadeIn();
    _index = $(this).find(".avatar").attr("id").replace("avatar", "") - 1;
    $(".progress_description").hide();
    $('.contributor').each(function() {
      $(this).velocity({
        backgroundColor: "#545454"
      }, 100);
    })
    $(this).velocity({
      backgroundColor: "#333"
    }, 100);

    options.animationSteps = 20;
    rebuildChart(30)
    $(".graph_title").html($(this).attr('id') + "'s Performance History")
  });
}
// ** END **

initPage()
