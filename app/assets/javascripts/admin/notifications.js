'use strict';

var _data = {};
var _dashboard;

jQuery(function($) {

// Populate _data
  _ajax({
      _ajaxType:'get',
      _url:'/a/notifications',
      _callback:function(data){
        _data.notifications = data;
        _dashboard = new AdminDashboard();
      }
  });

// Navigation Links
  $(document).on("click", ".admin_top_level_nav", function(e){
    $(".admin_top_level_nav").removeClass("active");
    if($(e.target).attr("href").replace("#admin-","")=="users") window.location="/a/users";
    if($(e.target).attr("href").replace("#admin-","")=="plans") window.location="/a/products";
    if($(e.target).attr("href").replace("#admin-","")=="quotes") window.location="/a/quotes";
  });

  function AdminDashboard() {

    function showArrow() {
      $('.js-dashboard_section_indicator.top_level').css('left', ($('#header_container nav a[href=#admin-notifications]').position().left+65)+'px');
      $('.js-dashboard_section_indicator.top_level').animate({'top':'-=15', 'opacity':1}, 300);
    }

    function showSummary() {
      EyeCueLab.UX.getTemplate(
        '/templates/admin/notifications/_summary.handlebars.html',
        '',
        $('.js-admin_dashboard_column.summary')
      );
    }

    function showNotifications(){
      EyeCueLab.UX.getTemplate(
        '/templates/admin/notifications/_list.handlebars.html',
        _data.notifications,
        $('.js-admin_dashboard_detail_container')
      );
    }

    function reloadData() {
      _ajax({
        _ajaxType:'get',
        _url:'/a/notifications',
        _callback: function(data){
          _data.notifications = data;
          _dashboard.showNotifications();
        }
      });
    }

    // Prevent Enter from Submitting Form
    $(document).ready(function() {
      $(window).keydown(function(event){
        if(event.keyCode == 13) {
          event.preventDefault();
          return false;
        }
      });
    });

    // Wire up the Post button
    $(document).on('click','.js-create_notification', function(e) {
      e.stopPropagation();
      e.preventDefault();
      _ajax({
        _ajaxType:'POST',
        _url:'/a/notifications/',
        _postObj:$('#admin-notifications-create_notification_form').serializeObject(),
        _callback:function(){
          _dashboard.reloadData();
        }
      });
    });

    // Wire up Remove X's on posts
    $(document).on('click','.js-remove_notification', function(e) {
      e.stopPropagation();
      e.preventDefault();
      var _notificationID = $(e.target).parents('.js-remove_notification').attr("data-notification_id");
      if (confirm("Are you sure you want to remove this notification?")) {
        _ajax({
          _ajaxType:'DELETE',
          _url:'/a/notifications/' + _notificationID,
          _callback:function(){
            _dashboard.reloadData();
          }
        });
      } else return;
    });

    // Function Accessors
    this.showNotifications = showNotifications;
    this.showSummary = showSummary;
    this.reloadData = reloadData;

    // Load Order
    showArrow();
    showSummary();
    showNotifications();
    // hideLoader();
  }
});
