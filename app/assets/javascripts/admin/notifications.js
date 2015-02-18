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

    // Wire up the Post button
    $(document).on('click','.js-create_notification', function(e) {
      e.stopPropagation();
      e.preventDefault();
      var _postObj = $('#admin-notifications-create_notification_form').serializeObject();
      _postObj.content = Autolinker.link(_postObj.content);
      _ajax({
        _ajaxType:'POST',
        _url:'/a/notifications/',
        _postObj: _postObj,
        _callback:function(){
          _dashboard.reloadData();
        }
      });
      $('#content').val('');
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

    // Wire up Load More button
    $(document).on('click','.js-load_more', function(e) {
      e.stopPropagation();
      e.preventDefault();

      var _nextPage = (_data.notifications.properties.paging.current_page) + 1;

      $('.js-load_more').remove();

      // Populate _data with next page
        _ajax({
            _ajaxType:'get',
            _url:'/a/notifications?page=' + _nextPage,
            _callback:function(data){
              _data.notifications = data;
              EyeCueLab.UX.getTemplate(
                '/templates/admin/notifications/_list.handlebars.html',
                _data.notifications,
                undefined,
                function(_returnHTML){
                  $('.js-admin_dashboard_detail_container').append(_returnHTML);

                  // If no more posts, remove the "Load More" button
                  if (_data.notifications.entities.length === 0) $('.js-load_more').remove();
                }
              );
            }
        });
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
