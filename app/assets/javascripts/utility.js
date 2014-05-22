//All jquery ajax requests must use CSRF token
$.ajaxSetup({
  headers: {
    'X-CSRF-Token': $('meta[name="csrf-token"]').attr("content")
  }
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


//utility to allow ajax post information
// _options._postObj is required for the data that is being posted
// _options._url is required to specify the endpoint
// _options._callback is optional to have a function that handles subsequent tasks after the post is done.
function ajaxPost(_options){
    var _postObj;
    if(_options._formObj !== undefined) _postObj = _formObj.serializeObject();
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
        type:"POST",
        data:_postObj,
        url:_options._url,
        dataType:"json",
        success: function(data, text){
            if(_options._callback !== undefined) _callback(data, text);
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
        ajaxPost(_options);

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












