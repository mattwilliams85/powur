'use strict';

// dashboard-topper.js
// functions for populating the top section of the dashboard

var DashboardTopper = {
  // function to fill first name in Welcome, [first_name] line
  fillFirstName: function() {
    $('#aw-first-name').text(_data.currentUser.first_name);
  },

  // function

  // function to fill news items feed
  // parameter _lastID is the ID of the last post shown on the page,
  // so the function knows where to start when getting more posts
  fillNewsItems: function(_lastID) {

  },

  // function to fill pay period goals from _data
  fillPayPeriodGoals: function() {

  },

  // function to get inspirational quote to share at bottom of dashboard topper
  fillShareQuote: function() {
    // share quotes will eventually be populated by a backend source:
    // var _shareQuotes = _data.dashboard_topper.share_quotes

    var _shareQuotes = [
      'The solar revolution has begun. Powur is leading the way by empowering' +
      ' everyday heroes. Find out more about this compelling opportunity.',
      'Only you can stop forest fires.',
      'Try to be a rainbow in someone\'s cloud.'
      ];
    var _randomIndex = Math.floor((Math.random() * _shareQuotes.length));
    $('.aw-share-quote').text(_shareQuotes[_randomIndex]);
  },

  fadeItIn: function() {
    $('.aw-fade-in').animate({'opacity':'1'}, 500);
    $('#group_rooftops .highlight_container .highlight').animate({'width':'54%'}, 1000);
    $('#personal_rooftops .highlight_container .highlight').animate({'width':'72%'}, 1000);
  },

  // function to run all of the above
  readyGO: function() {
    this.fillFirstName();
    this.fillNewsItems();
    this.fillPayPeriodGoals();
    this.fillShareQuote();
    this.fadeItIn();
  },

};