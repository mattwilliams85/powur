jQuery(function($){
    //All jquery ajax requests must use CSRF token
    $.ajaxSetup({
      headers: {
        'X-CSRF-Token': $('meta[name="csrf-token"]').attr("content")
      }
    });

    //Utility added to jQuery that allows drilldowns to scroll to view
    $.fn.scrollView = function (_offset) {
        if(_offset = undefined) _offset=0;
      return this.each(function (_offset) {
        $('html, body').animate({
          scrollTop: $(this).offset().top-_offset
        }, _animation_speed);
      });
    }


    //Utility to allow JSON objects to be serialized from forms
    $.fn.serializeObject = function()
    {
        console.log("start")
        var o = {};
        var a = this.serializeArray();
        $.each(a, function() {
            if (o[this.name] !== undefined) {
                if (!o[this.name].push) {
                    o[this.name] = [o[this.name]];
                }
                o[this.name].push(this.value || '');
            } else {
                o[this.name] = this.value || '';
            }
        });
        return o;
    };

});

//Handlebar helper to allow comparisons
Handlebars.registerHelper('compare', function(lvalue, rvalue, options) {
    if (arguments.length < 3)
        throw new Error("Handlerbars Helper 'compare' needs 2 parameters");
    operator = options.hash.operator || "==";
    var operators = {
        '==':       function(l,r) { return l == r; },
        '===':      function(l,r) { return l === r; },
        '!=':       function(l,r) { return l != r; },
        '<':        function(l,r) { return l < r; },
        '>':        function(l,r) { return l > r; },
        '<=':       function(l,r) { return l <= r; },
        '>=':       function(l,r) { return l >= r; },
        'typeof':   function(l,r) { return typeof l == r; }
    }

    if (!operators[operator])
        throw new Error("Handlerbars Helper 'compare' doesn't know the operator "+operator);

    var result = operators[operator](lvalue,rvalue);

    if( result ) {
        return options.fn(this);
    } else {
        return options.inverse(this);
    }
});




//utility to allow ajax post information
// _options._postObj is required for the data that is being posted
// _options._url is required to specify the endpoint
// _options._callback is optional to have a function that handles subsequent tasks after the post is done.
function _ajax(_options){
    var _postObj;
    var _ajaxType = "POST";

    if(_options._ajaxType !== undefined) _ajaxType = _options._ajaxType;
    if(_options._postObj !== undefined) _postObj = _options._postObj;
    if(_postObj == ''){
        console.log("Post data missing");
        return false;
    }
    if(_options._url === undefined || _options._url === ""){
        console.log("Endpoint missing");
        return false;
    }

    $.ajax({
        type:_options._ajaxType,
        data:_postObj,
        url:_options._url,
        dataType:"json",
        success: function(data, text){
            if(typeof _options._callback === "function") _options._callback(data, text);
            else console.log(data);
        },
        error: function(request, status, error){
            console.log("Post error: "+request.responseText);
        }
    });
}


//Utlity to allow ajax upload
//_formInputObj is the input in the form that is responsible for selecting files from desktop
//_uploadEndpoint is the server-side endpoint that recieves the multipart upload
//optoinal: _options._fileNameDisplay shows the file that's been selected by user
//optional: _options._uploadProgressDisplay shows the upload progress
//optional: _callback function that is triggered after the upload has been completed 
function ajaxUpload(_formInputObj, _uploadEndpoint, _options, _callback){
	var _formData = new FormData();
	var _supportedFiles = /(\.jpg|\.jpeg|\.pdf|\.gif|\.png)$/i;

	_formInputObj.on("change", function(e){
		for(i=0;i<$(this).file.length;i++){
			_file = $(this).file[i];

			if(!!_file.type.match(_supportedFiles)){
				//display filename is display object is provided
				if(_options._uploadProgressDisplay !== undefined)
					_options._uploadProgressDisplay.html("Uploading "+_file.filename);

				_fileReader = new FileReader();
				_fileReader.on("onloadend", function(e){
					if(_options._uploadProgressDisplay !== undefined)
						_options._uploadProgressDisplay.html(_file.filename+" upload completed");
				});
				_fileReader.readAsDataURL(_file);
				_formData.append("attachments[]", _file);


			}else{
				if(_options._uploadProgressDisplay !== undefined)
					_options._uploadProgressDisplay.html(_file.filename+" is not a supported file.");
				console.log(_file.filename+" is not a supported file.")
			}
		}

		//upload file
        var _options={};
        _options._url = _uploadEndpoint;
        _options._postObj = _formdata;
        _ajax(_options);

		/*$.ajax({
			url: _uploadEndpoint,
			type: "POST",
			data: _formdata,
			processData: false,
			contentType: false,
			success: function (r) {
				if(_callback!==undefined) _callback();
			}
		});*/
	});

}




// function that handles form submission
function _formSubmit(_event, _formObj, _endPoint, _verb){
    _event.preventDefault();
    var _serializedData = _formObj;
    if(typeof _verb == "undefined") _verb = "POST";
    if(_formObj instanceof $) _serializedData = _formObj.serializeObject();

    _ajax({
        _ajaxType:_verb,  
        _postObj:_serializedData,
        _url:_endPoint,
        _callback: function(data, text){
            if(Object.keys(data)=="error") _formErrorHandling(_formObj, data.error);
            else{
                if(typeof data.redirect !== "undefined") window.location.replace(data.redirect);
                console.log(text);
            }
        }
    }); 
}

//function that handles error handling
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








