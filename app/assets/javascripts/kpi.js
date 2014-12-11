var scale = "week";
var _labels = [];
var position = 0;
var page = 1;
var now = new Date()
now = setCalendar()
var myChart = ""
var ctx = ""

function initKPI(){
  displayTimeScale()
  randomizeData(6);
  setScale();
  randomizeOrders();
  populateContributors();
  checkPage()
  ctx = $("#metricsChart").get(0).getContext("2d");
  if(chartType === "line") myChart = new Chart(ctx).Line(metricsData, options);
  if(chartType === "bar") myChart = new Chart(ctx).Bar(metricsData, options);
}

function randomizeOrders() {
  if(_data.team.entities){
    _data.team.entities.forEach(function(member) {
      member.properties.orders = Math.floor(Math.random() * 30 + 10)
    });
    _data.team.entities.forEach(function(member) {
      member.properties.quotes = Math.floor(Math.random() * 30 + 5)
    });
    _data.team.entities.forEach(function(member) {
        member.properties.avatar = randomAvatar()
    });
  }
}

function randomAvatar(){
  gender = ["men","women"]
  return "http://api.randomuser.me/portraits/med/" + gender[Math.floor(Math.random()*2)] + "/" + Math.floor(Math.random() * 97) + ".jpg"
}

function rebuildChart(){
  if(scale === "week") timeScale = 6
  if(scale === "month") timeScale = numberOfDaysInMonth() - 1
  displayTimeScale()
  myChart.destroy();
  randomizeData(timeScale)
  setScale()
  ctx.canvas.width = 670
  ctx.canvas.height = 330
  if(chartType === "line") myChart = new Chart(ctx).Line(metricsData, options);
  if(chartType === "bar") myChart = new Chart(ctx).Bar(metricsData, options);
}

function populateContributors() {
  switch(kpiType){
    case "conversion":
      _template = "/templates/_kpi_conversion_team_thumbnail.handlebars.html"
      break;
    case "genealogy":
      _template = "/templates/_kpi_genealogy_team_thumbnail.handlebars.html"
      break;
    case "earnings":
      _template = "/templates/_kpi_total_earnings_team_thumbnail.handlebars.html"
    break;
    case "hot_quotes":
      _template = "/templates/_kpi_hot_quotes_team_thumbnail.handlebars.html"
    break;
  }
  if(_data.team.entities) {
    var _contributors = $(".contributors");

    top_ten = _data.team.entities.slice(0, 9)

    top_ten.forEach(function(member) {
      _ajax({
        _ajaxType: "get",
        _url: "/u/users/" + member.properties.id + "/downline",
        _callback: function(data, text) {
          member.properties.downline_count = data.entities.length;
            EyeCueLab.UX.getTemplate(_template, member, undefined, function(html) {
            if ($('.contributor').length == top_ten.length) contributorEvents();
            _contributors.append(html);
          });
        }
      });
    });
  } else {
    contributorEvents();
  }
}

// ** CALENDAR FUNCTIONS **
function setScale() {
  _labels = [];
  
  if (scale == "week") {
    for (i = 0; i <= 6; i++) {
      _labels.push(now.addDays(i).getMonth() + 1 + "/" + (now.addDays(i).getDate()));
    }
  } else {
    for (i = 0; i <= numberOfDaysInMonth() - 1; i++) {
      _labels.push(now.addDays(i).getMonth() + 1 + "/" + (now.getDate() + i));
    }
  }
  options.scaleStepWidth = Math.ceil((Math.max.apply(Math, metricsData.datasets[0].data) * 1.2) / 12);
  metricsData.labels = _labels
}

function setCalendar() {
  if(scale === "week") {
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
  timeScale = 6;
  rebuildChart()
})

$('.forward').on("click", function() {
  calendarForward()
  timeScale = 6;
  rebuildChart()
})

$(".return_to_team").on("click", function(e) {
  $(".graph_title").html("Full Conversion History");
  $(".contributor, .user-contributor").css("background", "#545454");
  $(".progress_description").fadeIn();
  $(".return_to_team").hide();
  rebuildChart();
});

$(".current").on("click", function(e) {
  now = new Date()
  rebuildChart()
})

$(".time_scale .month").on("click", function() {
  scale = "month"
  setCalendar()
  options.pointDotRadius = 3;
  rebuildChart()
  $(".time_scale .week").removeClass("active");
  $(this).addClass("active");
})

$(".time_scale .week").on("click", function() {
  scale = "week"
  setCalendar()
  options.pointDotRadius = 4;
  rebuildChart()
  $(".time_scale .month").removeClass("active");
  $(this).addClass("active");
})

// ** PAGINATION FOR USERS **
$('.fa-caret-down').on("click", function(e) {
  if ($(this).hasClass("active")) {
      page += 1;
      position -= 284;
      animateContributors()
    };
});

$('.fa-caret-up').on("click", function(e) {
  if ($('.fa-caret-up').hasClass("active")) {
    page -= 1;
    position += 284;
    animateContributors()
  };
});

function animateContributors(){
  checkPage();
  $('.contributor').each(function() {
    $(this).velocity({
    }, 100);
  })
  $('.contributor').each(function() {
    $(this).velocity({
      translateY: position + "px"
    });
  })
}

function checkPage() {
  if (_data.team.entities) {
  page_total = _data.team.entities.length
  if (page === 1) {
    $('.fa-caret-up').css("opacity", "0.3").removeClass("active");
    if(page_total >= 5){
      $('.fa-caret-down').css("opacity", "1").addClass("active");
    }
  } else {
    $('.fa-caret-up').css("opacity", "1").addClass("active");
  }
  if (page >= (Math.ceil(page_total / 4))) {
    $('.fa-caret-down').css("opacity", "0.3").removeClass("active");
  }
  } else {
    $('.fa-caret-up').css("opacity", "0.3").removeClass("active");
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
  $(".contributor, .user-contributor").on("click", function(e) {
    e.preventDefault();
    e.stopPropagation();
    $(".return_to_team").fadeIn();
    _index = $(this).find(".avatar").attr("id").replace("avatar", "") - 1;
    $(".progress_description").hide();
    $('.contributor, .user-contributor').each(function() {
      $(this).velocity({
        backgroundColor: "#545454"
      }, 100);
    })
    $(this).velocity({
      backgroundColor: "#333"
    }, 100);

    options.animationSteps = 20;
    rebuildChart()
    if(kpiType === "conversion") $(".graph_title").html($(this).attr('id') + "'s Conversion History")
    if(kpiType === "genealogy") $(".graph_title").html($(this).attr('id') + "'s Growth History")
    if(kpiType === "earnings") $(".graph_title").html($(this).attr('id') + "'s Earnings History")
  });
}
// ** END **

//Returns week number from formated Date
Date.prototype.getWeek = function(){
    var d = new Date(+this);
    d.setHours(0,0,0);
    d.setDate(d.getDate()+4-(d.getDay()||7));
    return Math.ceil((((d-new Date(d.getFullYear(),0,1))/8.64e7)+1)/7);
};

//Add # of days to current date
Date.prototype.addDays = function(days)
{
    var d = new Date(this.valueOf());
    d.setDate(d.getDate() + days);
    return d;
}

Date.prototype.getWeekYear = function ()
{
    var target  = new Date(this.valueOf());
    target.setDate(target.getDate() - ((this.getDay() + 6) % 7) + 3);

    return target.getFullYear();
}
