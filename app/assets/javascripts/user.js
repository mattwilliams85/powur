
$(document).ready(function(){
	$("#user_login input").keypress(function(e){if(e.which == "13") _formSubmit(e, $("#user_login"), "/login");});
	$("#user_login .button").on("click", function(e){_formSubmit(e, $("#user_login"), "/login");});
});
