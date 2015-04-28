'use strict';

// Development Tool to Fill Progress Bars
var fillProgressBars = function(){
  $(function () {
    $('.progress-bar').each(function () {
      var t = $(this);
      var barPercentage = t.data('percentage');

          // add a div for the label text
          t.children('.label').append("<div class='label-text'></div>");

          // add some "gimme" percentage when data-percentage is <2
          if (parseInt((t.data('percentage')), 10) < 2) barPercentage = 2;

          // set up the left/right label flipping
          if (barPercentage > 50) {
            t.children('.label').css('right', (100 - barPercentage) + '%');
            t.children('.label').css('margin-right', '-10px');
          }
          if (barPercentage < 51) {
            t.children('.label').css('left', barPercentage + '%');
            t.children('.label').css('margin-left', '-20px');
          }

          // fill in bars and labels
          t.find('.label-text').text(t.attr('data-percentage') + ' Rooftops');
          t.children('.bar').animate({
            width: barPercentage + '%'
          }, 1000);
          t.children('.label').animate({
            opacity: 1
          }, 1000);
        });
  });
  return 'yeah!';
};


//JAVASCRIPT CLASS FUNCTIONS
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

//Week equivelent of getMonth()
Date.prototype.getWeekYear = function ()
{
  var target  = new Date(this.valueOf());
  target.setDate(target.getDate() - ((this.getDay() + 6) % 7) + 3);
  return target.getFullYear();
}
