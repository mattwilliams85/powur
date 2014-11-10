var _myID=0; //current user id
var _data={}; //main data object that contains user profile and genelogy info


jQuery(function($){
	$(document).ready(function(){
		//$("#user_login input").keypress(function(e){if(e.which == "13") _formSubmit(e, $("#user_login"), "/login");});

		$("#user_login .button").on("click", function(e){_formSubmit(e, $("#user_login"), "/login", "post", function(data, text){
            for(i=0;i<=data.links.length;i++)
                if(data.links[i].rel.indexOf("index")>=0) window.location=data.links[i].href;
            });
	    });
    });
});

jQuery(function($){
	$(document).ready(function(){
        _getRoot(function(){
            $(".js-user_first_name").text(_data.root.properties.first_name );
            _myID = _data.root.properties.id;
            if(_data.currentUser.thumb_image_url) $("#js-user_profile_image").attr("src", _data.currentUser.thumb_image_url);
        });

        $("#submit-photo").on("click", function(e){
            e.preventDefault();
            console.log("hi")
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
    });
});
