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
		$(".js-multi_form_submit").on("click", function(e){
               $(this).html('<i class="fa fa-check"></i> Saved!').addClass("saved_button");
			$(this).parents(".js-multi_form_fieldset").addClass("saved_fieldset").next(".js-multi_form_fieldset").removeAttr("disabled");
			e.preventDefault();
		});
    });
});
