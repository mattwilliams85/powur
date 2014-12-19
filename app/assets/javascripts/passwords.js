'use strict';

jQuery(function($){
  //wire up reset form
  $(document).on("click", "#user_reset_password_form button", function(e){
    e.preventDefault();
    _formSubmit(e, $("#user_reset_password_form"), "/password/", "post", function(data, text){
      if(typeof data.properties._message.confirm !=="undefined"){
        $("#user_reset_password_form").append("<div class='js-message secondary_button' style='display:none; margin-top:100px; color:#20c2f1;'>"+data.properties._message.confirm+"</div>");
        $("#user_reset_password_form .js-message").fadeIn();
        $("#user_reset_password_form span.form_row, #user_reset_password_form button, #user_reset_password_form a").fadeOut();
      }
    });
  });

  //wire up update form
  $(document).on("click", "#user_update_password_form button", function(e){
    e.preventDefault();
    _formSubmit(e, $("#user_update_password_form"), "/password/", "put", function(data, text){
      console.log(data);
      if(typeof data.properties._message.confirm !=="undefined"){
        $("#user_update_password_form").append("<div class='js-message secondary_button' style='display:none; margin-top:100px; color:#20c2f1;'>"+data.properties._message.confirm+"</div>");
        $("#user_update_password_form .js-message").fadeIn();
        $("#user_update_password_form span.form_row, #user_update_password_form button").fadeOut();
      }
    });
  });
});
