'use strict';

// dashboard-topper.js
// functions for populating the top section of the dashboard

var DashboardTopper = {
  // function to fill first name in Welcome, [first_name] line
  fillFirstName: function() {
    $('#aw-first-name').text(_data.currentUser.first_name);
  },

  // function to fill in avatar
  fillAvatar: function() {
    if(_data.currentUser.avatar) $('#aw-avatar').attr('src', _data.currentUser.avatar.large);
  },

  // function to fill news items feed
  // parameter _lastID is the ID of the last post shown on the page,
  // so the function knows where to start when getting more posts
  fillNewsItems: function(_lastID) {

  },

  // function to fill pay period goals from _data
  fillPayPeriodGoals: function() {
    // set the tooltip text
    $('#personal_rooftops_tooltip').text('3 of 5 Personal Rooftops');
    $('#group_rooftops_tooltip').text('9 of 20 Group Rooftops');
    // animate the fill of the meter
    $('#personal_rooftops .highlight_container .highlight').animate({'width':'60%'}, 1000);
    $('#group_rooftops .highlight_container .highlight').animate({'width':'45%'}, 1000);
  },

  // function to get inspirational quote to share at bottom of dashboard topper
  fillShareQuote: function() {
    // share quotes will eventually be populated by a backend source:
    // var _shareQuotes = _data.dashboard_topper.share_quotes

    var _shareQuotes = [
      'The solar revolution has begun. Powur is leading the way by empowering' +
      ' everyday heroes. Find out more about this compelling opportunity.',
      'We\'re cutting yearly energy costs by thousands of dollars for homeowners across' +
      ' the United States. Powur advocates are helping us save the world with sunshine.',
      'Turn a sunny day into a sustainable future. Join Powur and start taking back' +
      ' the future of energy!'
      ];
    var _randomIndex = Math.floor((Math.random() * _shareQuotes.length));
    $('.aw-share-quote').text(_shareQuotes[_randomIndex]);
  },

  fadeOutLoader: function() {
    $('.aw-spinner').hide();
  },

  fadeItIn: function() {
    $('.aw-fade-in').animate({'opacity':'1'}, 500);
  },

  // function to run all of the above
  readyGO: function() {
    this.fillFirstName();
    this.fillAvatar();
    this.fillNewsItems();
    this.fillPayPeriodGoals();
    this.fillShareQuote();
    this.fadeOutLoader();
    this.fadeItIn();
  },

};