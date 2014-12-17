var _myID=0; //current user id
var _data={}; //main data object that contains user profile and genelogy info

$(window).bind('page:change', function() {
  initPage();
});

function initPage(){
  _getRoot(function(){
    $(".js-user_first_name").text(_data.root.properties.first_name );
    _myID = _data.root.properties.id;
    if(_data.currentUser.avatar) $("#js-user_profile_image").attr("src", _data.currentUser.avatar.thumb);
  });

  $("#submit-photo").on("click", function(e){
    e.preventDefault();
    $("#user_avatar").click();
  });

  $("#user_avatar").on("change", function(e) {
    $(this).parent("form").submit();
  });

  $(".js-multi_form_submit").on("click", function(e){
    $(this).html('<i class="fa fa-check"></i> Saved!').addClass("saved_button");
    //$(this).parents(".js-multi_form_fieldset").addClass("saved_fieldset").next(".js-multi_form_fieldset").removeAttr("disabled");
    $(".js-multi_form_fieldset").removeAttr("disabled");
    e.preventDefault();
  });
};
