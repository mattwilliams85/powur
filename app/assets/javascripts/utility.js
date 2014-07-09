jQuery(function($){
    //All jquery ajax requests must use CSRF token
    $.ajaxSetup({
        headers: {
            'X-CSRF-Token': $('meta[name="csrf-token"]').attr("content"),
            Accept : 'application/json; charset=utf-8'
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

//Handlebar helper to allow mathematical calculations
Handlebars.registerHelper("math", function(lvalue, operator, rvalue, options) {
    lvalue = parseFloat(lvalue);
    rvalue = parseFloat(rvalue);
        
    return {
        "+": lvalue + rvalue,
        "-": lvalue - rvalue,
        "*": lvalue * rvalue,
        "/": lvalue / rvalue,
        "%": lvalue % rvalue
    }[operator];
});


//utility to allow ajax post information
// _options._postObj is required for the data that is being posted
// _options._url is required to specify the endpoint
// _options._callback is optional to have a function that handles subsequent tasks after the post is done.
function _ajax(_options){
    var _postObj = {};
    var _ajaxType = "post";
    var _dataType = "json";
    if(_options._ajaxType !== undefined) _ajaxType = _options._ajaxType;
    if(_options._postObj !== undefined) _postObj = _options._postObj;
    if(_ajaxType.toLowerCase() == "post" && (_postObj == '' || typeof _postObj == "undefined")){
        console.log("Post data missing");
        return false;
    }
    if(_options._url === undefined || _options._url === ""){
        console.log("Endpoint missing");
        return false;
    }
    //if (_ajaxType.toLowerCase() =="delete") _dataType="html";

    $.ajax({
        type:_ajaxType,
        data:_postObj,
        url:_options._url,
        dataType:_dataType,
        success: function(data, text){
            if(typeof _options._callback === "function") _options._callback(data, text);
            else return data;
        },
        error: function(request, status, error){
            console.log("Post error: "+error.message);
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
	});

}




// function that handles form submission
function _formSubmit(_event, _formObj, _endPoint, _verb, _callback){
    _event.preventDefault();
    var _serializedData = _formObj;
    if(typeof _verb == "undefined") _verb = "POST";
    if(_formObj instanceof $) {
        _serializedData = _formObj.serializeObject();
        _formObj.find(".form_row").removeClass("is_not_valid");
        _formObj.find(".js-error").remove();
    }

    _ajax({
        _ajaxType:_verb,  
        _postObj:_serializedData,
        _url:_endPoint,
        _callback: function(data, text){
            if(Object.keys(data)=="error") _formErrorHandling(_formObj, data.error);
            else{
                if(typeof data.redirect !== "undefined") window.location.replace(data.redirect);
                if(typeof _callback !== "undefined") _callback(data, text);
            }
        }
    }); 
}

//function that handles error handling
function _formErrorHandling(_formObj, _error){
    switch (_error.type){
        case "input":
            _input= _formObj.find("input[name='"+_error.input+"']");
             _formObj.find("input[name='"+_error.input+"']").parents(".form_row").addClass("is_not_valid");
            _formObj.find(".js-error").remove();
            _html="<span class='js-error'>"+_error.message+"</span>";
            _input.parents(".form_row").prepend(_html);

        break;

    }
}


//get root object (user info, etc.)
function _getRoot(_callback){
    $.ajax({
        type:"get",
        url:"/",
        data:{}
    }).done(function(data, text){
        if(typeof _data === "object" )_data.root = $.extend(true, {}, data);
        else console.log(data);
        
        if(typeof _callback === "function") _callback();
     });
}    



//fire query after a bit of a wait
//_options must contain a _callback function to allow search results to be passed back asynchronously
function _queryServer(_options){
    _searchSource=$(_options._event.target).attr("data-search-source");
    _q=$(_options._event.target).val();
    _target =$(_options._event.target);

    _ajax({_ajaxType:"get", _url:"/"+_searchSource, _postObj:{q:_q}, _callback:function(data, text){
        if(typeof _options._callback === "function") _options._callback(data);
        else console.log(data);
        }
    });
}




//****** json utilities  *******//


//function that returns the sub objects within json that matches certain
//_dataObj: required, the main JSON that you would like to to search from
//_criteria: required, there are 3 ways to specify _criteria:
//  "val=xxx" returns all objects that contain values that match xxx exactly
//  "key=xxx" returns all objects that contain keys that match xxx exactly
//  "val~xxx" returns all objects that contain values that match xxx partially (somewhere in the string)
//  "key~xxx" returns all objects that contain keys that match xxx partially (somewhere in the string)
//  {xxx:"yyy"} returns all objects that contain keys that match xxx AND values that match "yyy" 
//_results: optional, the object that stores the result
//_path: internal, do not pass in _path information
function _getObjectsByCriteria(_dataObj, _criteria, _results, _path){
    if(typeof _path === "undefined") _path="";
    if(typeof _results === "undefined") _results = [];
    if(!_results instanceof Array) _results = [];

    if(typeof _criteria === "undefined" ) return;
    var _value, _key, _json, _operator;

    if(typeof _criteria === "object" ) _json=_criteria;
    if(typeof _criteria === "string" ) {
        _operator = _criteria.indexOf("=")>=0? "=":undefined;
        if(!_operator)_operator = _criteria.indexOf("~")>=0? "~":undefined;

        if(typeof _operator === "undefined") return;
        _value=  ["val", "value"].indexOf(_criteria.split(_operator)[0].toLowerCase() >=0)? _criteria.split(_operator)[1]:undefined;
        _key= ["key"].indexOf(_criteria.split(_operator)[0].toLowerCase() >=0)?  _criteria.split(_operator)[1]:undefined;
    }

    Object.keys(_dataObj).forEach(function(key){
        if(_dataObj[key] === null) _dataObj[key]="";

        if(_operator==="="){
            if((typeof _value !== "undefined") && (typeof _dataObj[key]==="string") && (_dataObj[key].toLowerCase() ===_value.toLowerCase()) ) _results.push(_dataObj);
            if((typeof _key !== "undefined") && (key.toLowerCase() ===_key.toLowerCase()) ) _results.push(_dataObj);
        }
        if(_operator==="~"){
            if((typeof _value !== "undefined") && (typeof _dataObj[key]==="string") && (_dataObj[key].toLowerCase().indexOf(_value.toLowerCase())>=0) ) _results.push(_dataObj);
            if((typeof _key !== "undefined") && (key.toLowerCase().indexOf(_key.toLowerCase())>=0) ) _results.push(_dataObj);

        }
        if((typeof _json !== "undefined") && (typeof _dataObj[key]==="string") && (key.toLowerCase() === Object.keys(_json)[0].toLowerCase()) && (_dataObj[key].toLowerCase() ===_json[Object.keys(_json)[0]].toLowerCase())) _results.push(_dataObj);

        //recursively look through the rest of the JSON
        if(!!_dataObj[key] && typeof _dataObj[key] === "object" && Object.keys(_dataObj[key]).length>0) {
            _dataObj[key]["_path"]=_path+"/"+key;
            _getObjectsByCriteria(_dataObj[key], _criteria, _results, _dataObj[key]["_path"]);
        }
    });
    return _results;
}

// returns the object by path.  
// optional _parentLevel provides ability to traverse up the JSON tree: -1 returns parent, -2 returns two levels up, etc.
function _getObjectsByPath(_dataObj, _path, _parentLevel){
    if(typeof _parentLevel === "undefined") _parentLevel=0;
    if(typeof _dataObj !== "object") return;
    if(typeof _path !== "string") return;

    _evalString="_dataObj";
    _depth=_path.split("/");
    if(_depth[0]==="") _depth.shift();
    for (i=_parentLevel;i<0;i++) _depth.pop();

    _depth.forEach(function(_d) {_evalString+="[\""+_d+"\"]"});
    return eval(_evalString);;
}



