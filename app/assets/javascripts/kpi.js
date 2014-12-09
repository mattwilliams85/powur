var scale = "week";
var _labels = [];
var position = 0;
var page = 1;
var page_total = _data.team.entities.length
var now = new Date()
now = setCalendar()
var myChart = ""
var ctx = ""

function initPage(){
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

function randomAvatar(){
  gender = ["men","women"]
  return "http://api.randomuser.me/portraits/med/" + gender[Math.floor(Math.random()*2)] + "/" + Math.floor(Math.random() * 97) + ".jpg"
}

function rebuildChart(scale){
  displayTimeScale()
  myChart.destroy();
  randomizeData(scale)
  setScale()
  ctx.canvas.width = 670
  ctx.canvas.height = 330
  if(chartType === "line") myChart = new Chart(ctx).Line(metricsData, options);
  if(chartType === "bar") myChart = new Chart(ctx).Bar(metricsData, options);
  if(scale === "month") options.barValueSpacing = 3;
  if(scale === "week") options.barValueSpacing = 20;
}

function populateContributors() {
  var _contributors = $(".contributors");

  top_ten = _data.team.entities.slice(0, 9)

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
  if(scale == "month") timeScale = numberOfDaysInMonth() - 1
  rebuildChart(timeScale)
})

$('.forward').on("click", function() {
  calendarForward()
  timeScale = 6;
  if(scale == "month") timeScale = numberOfDaysInMonth() - 1
  rebuildChart(timeScale)
})

$(".return_to_team").on("click", function(e) {
  rebuildChart(numberOfDaysInMonth() - 1)
  $(".graph_title").html("Full Conversion History");
  $(".contributor, .user-contributor").css("background", "#545454");
  $(".progress_description").fadeIn();
  $(".return_to_team").hide();
});

$(".current").on("click", function(e) {
  now = new Date()
  rebuildChart(29)
})

$(".time_scale .month").on("click", function() {
  scale = "month"
  setCalendar()
  rebuildChart(29)
  $(".time_scale .week").removeClass("active");
  $(this).addClass("active");
})

$(".time_scale .week").on("click", function() {
  scale = "week"
  setCalendar()
  rebuildChart(6)
  $(".time_scale .month").removeClass("active");
  $(this).addClass("active");
})

// ** PAGINATION FOR USERS **
$('.fa-caret-down').on("click", function(e) {
  if ($(this).hasClass("active")) {
      page += 1;
      position -= 290;
      animateContributors()
    };
});

$('.fa-caret-up').on("click", function(e) {
  if ($('.fa-caret-up').hasClass("active")) {
    page -= 1;
    position += 290;
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
    if(page_total >= 5){
      $('.fa-caret-down').css("opacity", "1").addClass("active");
    }
  } else {
    $('.fa-caret-up').css("opacity", "1").addClass("active");
  }
  if (page >= (page_total / 4) - 1) {
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
    console.log(this)
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
    rebuildChart(29)
    $(".graph_title").html($(this).attr('id') + "'s Conversion History")
  });
}
// ** END **

