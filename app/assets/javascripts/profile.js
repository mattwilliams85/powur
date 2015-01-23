'use strict';

var _myID=0; //current user id
var _data={}; //main data object that contains user profile and genelogy info

function initPage() {
  _getRoot(function(){
    if ((_data.root.properties.first_name).length >= 11) {
      $('.js-user_first_name').text(_data.root.properties.first_name.substring(0,12) + '...');
    } else {
      $('.js-user_first_name').text(_data.root.properties.first_name );
    }
    _myID = _data.root.properties.id;
    if(_data.currentUser.avatar) $('#js-user_profile_image')
      .attr('src', _data.currentUser.avatar.thumb);
  });

  $('#submit-photo').on('click', function(e){
    e.preventDefault();
    $('#user_avatar').click();
  });

  $('#user_avatar').on('change', function() {
    $(this).parent('form').submit();
  });

  $('.js-multi_form_submit').on('click', function(e){
    $(this).html('<i class=\'fa fa-check\'></i> Saved!')
      .addClass('saved_button');
    $('.js-multi_form_fieldset').removeAttr('disabled');
    e.preventDefault();
  });
}

$(window).bind('page:change', function() {
  initPage();
});
