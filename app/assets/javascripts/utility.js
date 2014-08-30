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
                if(this.name==="source") o[this.name]=true;
                else if(this.name==="compress") o[this.name]=true;
                else o[this.name] = this.value || '';
            }
        });
        return o;
    };

});


Handlebars.registerHelper('sanitize', function(_value){
    _value = _value.replace("_", " ");
    _value = _value.replace(/percentage/gi, "\%");
    if(_value.length==0) _value="<span class='js-no_data'>No Data</span>";
    return _value.replace("_", " ");
})

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
    if(typeof _dataObj === "undefined") return;
    var _value, _key, _json, _operator;

    if(typeof _criteria === "object" ) _json=_criteria;
    if(typeof _criteria === "string" ) {
        _operator = _criteria.indexOf("=")>=0? "=":undefined;
        if(!_operator)_operator = _criteria.indexOf("~")>=0? "~":undefined;

        if(typeof _operator === "undefined") return;
        var _value= (["val", "value"].indexOf(_criteria.split(_operator)[0].toLowerCase())>=0)? _criteria.split(_operator)[1]:undefined;
        var _key=   (["key"].indexOf(_criteria.split(_operator)[0].toLowerCase())>=0)?  _criteria.split(_operator)[1]:undefined;
    }

    Object.keys(_dataObj).forEach(function(key){
        if(_dataObj[key] === null) _dataObj[key]="";

        if(_operator==="="){
            if((typeof _value !== "undefined") && (_dataObj[key] ===_value) ) _results.push(_dataObj);
            if((typeof _key !== "undefined") && (key.toLowerCase() ===_key.toLowerCase()) ) _results.push(_dataObj);
        }
        if(_operator==="~"){
            if((typeof _value !== "undefined") && (typeof _dataObj[key] === "string") && (_dataObj[key].indexOf(_value)>=0) ) _results.push(_dataObj);
            if((typeof _key !== "undefined") && (key.toLowerCase().indexOf(_key.toLowerCase())>=0) ) _results.push(_dataObj);

        }
        if((typeof _json !== "undefined") && (key.toLowerCase() === Object.keys(_json)[0].toLowerCase()) && (_dataObj[key] ==_json[Object.keys(_json)[0]])) _results.push(_dataObj);

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

//create admin popups
function _formatPopupData(e, _options){
    e.preventDefault();
    if(! _options._dataObj) return;
    var _popupData=[];
    _popupData = _options._dataObj;
    if(!!_popupData.fields)
        _popupData.fields.forEach(function(field){
            field.display_name=field.name.replace(/\_/g," ");
            if(typeof field.options !=="undefined") delete field.options["_path"];
        });

    if(!!_options._title) _popupData.title = _options._title;
    if(!!_options._href) _popupData.href = _options._href;
    if(!!_options._deleteOption){
        _popupData.deleteOption = {};
        $.extend(true, _popupData.deleteOption, _options._deleteOption);
    }
 
    return _popupData;
}

function _paginateData(_dataObj, _options){
    if(!_options.actionableCount || _options.actionableCount <5) _options.actionableCount=5;
    if(!_options.useControls) _options.useControls=true;
    if(!_options.prefix) _options.prefix="js-page";

    var _currentPage = _dataObj.value;
    var _startPage = ((_currentPage - Math.ceil(_options.actionableCount/2))>=1)? (_currentPage - Math.ceil(_options.actionableCount/2)):1;
    var _endPage = ((_currentPage + Math.ceil(_options.actionableCount/2))<_dataObj.max)? (_currentPage + Math.ceil(_options.actionableCount/2)):_dataObj.max;
    var _pages = [];
    if(_startPage>2) {
        _pages.push({display:1, link:_options.prefix+" 1"});
        _pages.push({display:"...", link:""});
    }
    if(_startPage==2) _pages.push({display:1, link:_options.prefix+" 1"});

    for(i=_startPage; i<=_endPage; i++){
        if(i==_currentPage) _pages.push({display:i, link:""});
        else _pages.push({display:i, link:_options.prefix+" "+i});
    }

    if(_endPage<_dataObj.max-1){
        _pages.push({display:"...", link:""});
        _pages.push({display:_dataObj.max, link:_options.prefix+" "+_dataObj.max});
    }
    if(_endPage == _dataObj.max-1) _pages.push({display:_dataObj.max, link:_options.prefix+" "+_dataObj.max});

    var returnObj={};
    returnObj.currentPage = _currentPage;
    returnObj.startPage = _startPage;
    returnObj.endPage = _endPage;
    returnObj.display = _pages;
    return returnObj;
}


//Usage:
//  EyeCueLab.JSON.getObjectsByPattern( data, 
//                                      {"containsIn(class)":["bonuses", "list"], 
//                                       "containsIn(links)":[{rel: "self"}]}
//  )

(function(EyeCueLab, $, undefined){
    EyeCueLab.JSON = {}; //namespace
    EyeCueLab.JSON.getObjectsByPattern = function(_dataObj, _pattern, _results, _searchCriteria){
        if(!_searchCriteria) {
            _searchCriteria = {};
            Object.keys(_pattern).forEach(function(_key){
                if(_key.indexOf("containsIn") >=0) _searchCriteria[(_key.replace(/(containsIn)*(\(|\))*/g,""))]=_pattern[_key]; 
            });
        }
        if(!_results) _results=[];
        
        Object.keys(_dataObj).forEach(function(_dataKey){
            var breakException = {};
            try{
                Object.keys(_searchCriteria).forEach(function(_searchKey){
                    //check for key match
                    if(!_dataObj[_searchKey]) throw breakException;

                    //check for value match
                    var _matchFound=0;
                    for(i=0; i<_searchCriteria[_searchKey].length;i++){
                        _searchCriterion={
                            term:_searchCriteria[_searchKey][i],
                            type:Object.prototype.toString.call(_searchCriteria[_searchKey][i]).replace(/(\[object\s|\])/g,"" )
                        };

                        switch(_searchCriterion.type){
                            case "Object":
                                _sk = Object.keys(_searchCriterion.term)[0];

                                //loop through the data object if the type is array (e.g. actions)
                                if(Object.prototype.toString.call(_dataObj[_searchKey]).replace(/(\[object\s|\])/g,"" )=="Array"){
                                    for(i=0;i<_dataObj[_searchKey].length;i++){
                                        Object.keys(_dataObj[_searchKey][i]).forEach(function(_dk){
                                            if((_sk==_dk) && (_searchCriterion.term[_sk]==_dataObj[_searchKey][i][_dk])) _matchFound+=1;
                                        });
                                    }
                                }
                                // try to match directly if the data object is JSON (e.g. properties)
                                if(Object.prototype.toString.call(_dataObj[_searchKey]).replace(/(\[object\s|\])/g,"" )=="Object"){
                                    Object.keys(_dataObj[_searchKey]).forEach(function(_dk){
                                        if((_sk==_dk) && (_searchCriterion.term[_sk]==_dataObj[_searchKey][_dk])) _matchFound+=1;
                                    });
                                }
                            break;

                            case "String":
                                //string, search through the immediate containing values (e.g. class, properties)
                                Object.keys(_dataObj[_searchKey]).forEach(function(_k){
                                    if(_dataObj[_searchKey][_k] === _searchCriterion.term) _matchFound+=1; 
                                });
                            break;
                        }
                    }
                    //break when not all conditions within a searchKey are met
                    if(_matchFound<_searchCriteria[_searchKey].length) throw breakException;

                });

                //use _path to check redundancy
                _results.forEach(function(_result){if(_result === _dataObj) throw breakException;});
                _results.push(_dataObj);

            }catch(e){ 
                if(e !==breakException) throw e;
            }

            if(!!_dataObj[_dataKey] && typeof _dataObj[_dataKey] === "object" && Object.keys(_dataObj[_dataKey]).length>0) {
                EyeCueLab.JSON.getObjectsByPattern(_dataObj[_dataKey], _pattern, _results, _searchCriteria);
            }
        });
        return _results;
    }

}(window.EyeCueLab = window.EyeCueLab || {}, jQuery));

