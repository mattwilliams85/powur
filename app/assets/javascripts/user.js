
$(document).ready(function(){
	$("#user_login input").keypress(function(e){if(e.which == "13") _formSubmit(e, $("#user_login"), "/login");});
	$("#user_login .button").on("click", function(e){_formSubmit(e, $("#user_login"), "/login");});
});


function _formSubmit(_event, _formObj, _endPoint){
	_event.preventDefault();
	ajaxPost({	
		_postObj:_formObj.serializeObject(),
		_url:_endPoint,
		_callback: function(data, text){
			if(Object.keys(data)=="error") _formErrorHandling(_formObj, data.error);
			else{
				window.location.replace(data.redirect);
			}
		}
	});	
}

function _formErrorHandling(_formObj, _error){
	switch (_error.type){
		case "input":
			_input= _formObj.find("input[name='"+_error.input+"']");
			_formObj.find(".js-error").remove();
			_html="<span class='js-error'>"+_error.message+"</span>";
			_input.parents(".form_row").append(_html);
		break;

	}
}