'use strict';

jQuery(function($){
    //All jquery ajax requests must use CSRF token
    $.ajaxSetup({
        headers: {
            'X-CSRF-Token': $('meta[name="csrf-token"]').attr("content"),
            Accept : 'application/json; charset=utf-8',
        },
        cache: false
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

//browser specific rules function 
function applyBrowserSpecificRules() {
  if (navigator.userAgent.indexOf('Chrome') !== -1) {
    // (chrome-specific stuff here)
  } else if (navigator.userAgent.indexOf('Opera') !== -1) {
    // (opera-specific stuff here)
  } else if (navigator.userAgent.indexOf('Firefox') !== -1) {
    // (firefox-specific stuff here)

    //dropdown arrows workaround for FF 34 and below
    //test for Firefox/x.x or Firefox x.x (ignoring remaining digits);
    if (/Firefox[\/\s](\d+\.\d+)/.test(navigator.userAgent)){ 
      var _selects;
      var i;
      // capture x.x portion and store as a number
      var ffversion = new Number(RegExp.$1); 
      if (ffversion >= 35) {
        _selects = document.querySelectorAll('select');
        for (i=0; i<_selects.length; i++) {
          _selects[i].style.backgroundImage = '/assets/select_arrow.svg';
        }
      } else {
        _selects = document.querySelectorAll('select');
        for (i=0; i<_selects.length; i++) {
          _selects[i].style.backgroundImage = 'none';
        }
      }
    }
  } else if ((navigator.userAgent.indexOf('MSIE') !== -1) || 
    (document.documentMode === true)) {
    // (IE-specific stuff here)
  } else {
    // (browser isn't one of the above)
  }
}


Handlebars.registerHelper("debug", function(optionalValue) {
  console.log("Current Context");
  console.log("====================");
  console.log(this);

  if (optionalValue) {
    console.log("Value");
    console.log("====================");
    console.log(optionalValue);
  }
});

Handlebars.registerHelper('sanitize', function(_value){
    _value = _value.replace("_", " ");
    _value = _value.replace(/percentage/gi, "\%");
    if(_value.length==0) _value="<span class='js-no_data'>No Data</span>";
    return _value.replace("_", " ");
});

Handlebars.registerHelper('localtime', function(_value){
    var _t = new Date(_value);
    return (_t.getMonth()+1)+"/"+(_t.getDate())+"/"+(_t.getFullYear());
});



Handlebars.registerHelper('contains_in_array', function(a, v, options){
    return (a.indexOf(v)>=0)?options.fn(this):options.inverse(this);
})

//return array element from index
Handlebars.registerHelper('index_of', function(context,ndx) {
  return context[ndx];
});

//Handlebar helper to allow comparisons
Handlebars.registerHelper('compare', function(lvalue, rvalue, options) {
    if (arguments.length < 3)
        throw new Error("Handlerbars Helper 'compare' needs 2 parameters");
    var operator = options.hash.operator || "==";
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

//Handlebar helper to dispay numbers as currency
Handlebars.registerHelper('formatCurrency', function(amount) {
    return parseInt(amount).toFixed(0).toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,");
});

//Handlebar helper to change underscores to dashes
Handlebars.registerHelper('formatUnderscore', function(string) {
    return string.replace(/[_]/g, '-');
});

//Handlebar helper to dispay correct name for month number
Handlebars.registerHelper('formatMonth', function(monthNumber) {
    var monthNames = [ "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December" ];
    return monthNames[monthNumber]
});

//Handlebar helper function compare new variable to previously stored variable
//Can also be used to detect change in group type
var storedJson = ""

Handlebars.registerHelper('storeJson', function(json) {
    storedJson = json;
});

Handlebars.registerHelper('compareJson', function(json, options) {  
  if(json === storedJson) return options.fn(this);
  else return options.inverse(this);
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

Handlebars.registerHelper("format_length", function(str, char_limit) {
    char_limit = parseInt(char_limit);
    if(str.length > char_limit) return str.substring(0,char_limit).trim() + "...";
    else return str;
})

Handlebars.registerHelper("format_fullname_length", function(firstName, lastName, char_limit) {
    char_limit = parseInt(char_limit);
    if((firstName.length + lastName.length) > char_limit) return (firstName + " " + lastName).substring(0,char_limit).trim() + "...";
    else return (firstName + " " + lastName);
})

//Handlebar helper to parse JSON objects
Handlebars.registerHelper('json', function(context) {
    return JSON.stringify(context);
});


/** start admin utilties **/

$(document).on("click", "#js-screen_mask", function(e){
    if(!$(e.target).attr("id") || $(e.target).attr("id")!=="js-screen_mask") return;
    $("#js-popup").animate({opacity:0, top:"-=50"},200, function(){
        $("#js-screen_mask").fadeOut(100, function(){
            $("body").css("overflow", "auto");
            $("#js-popup").remove();
        });
    });
    return;
});




$(window).resize(function(){
    $("#js-popup").css({"left":(($(window).width()/2)-240)+"px","top":"200px"});
    //%TODO: recalculate x position for the indicators
})

jQuery(function($){

(function(SunStand, $, undefined){
    SunStand.Admin = {}; //namespace
    SunStand.UX={};

    SunStand.UX.paginateData = function(_dataObj, _options){
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

        for(var i=_startPage; i<=_endPage; i++){
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


    SunStand.Admin.displayPopup = function(_options){
        if(!_options._css) _options._css={};
        if(!_options._css.width) _options._css.width=480;
        if(!_options._css.maxHeight) _options._css.maxHeight = $(window).height()-400;
        if(!_options._css.opacity) _options._css.opacity=0;
        if(!_options._css.top) _options._css.top=150;
        $("body").css("overflow", "hidden");
        $("#js-popup").css("overflow","auto");
        $("#js-popup").css({"left":(($(window).width()/2)-(_options._css.width/2))+"px","top":_options._css.top+"px", opacity:_options._css.opacity});
        $("#js-popup").css("width", _options._css.width+"px");
        $("#js-popup").css("max-height", _options._css.maxHeight);
        if($("#js-popup").css("opacity")==0) $("#js-popup").animate({opacity:1, top:"+=30"}, 200);
        $(".js-popup_form_button").on("click", function(e){
            e.preventDefault();
            _ajax({
                _ajaxType:_options._popupData.method,
                _url:_options._popupData.href,
                _postObj: $("#js-popup_form").serializeObject(),
                _callback:function(data, text){
                    $("#js-screen_mask").click();
                    $("body").css("overflow", "auto");

                    if(typeof _options._callback === "function") _options._callback();
                }
            });
        });


        //wire up pagination if it exists
        $(".js-pagination a").on("click", function(e){
            e.preventDefault();
            var _action = _getObjectsByCriteria(_options._popupData.actions, {name:"list"})[0];
            _ajax({
                _ajaxType:_action.method,
                _url:_action.href,
                _postObj:{page:$(e.target).attr("data-page-number").split(" ")[1]},
                _callback:function(data, text){
                    _popupData=data;
                    _popupData.paginationInfo=_paginateData(_getObjectsByCriteria(data, {name:"page"})[0], {prefix:"js-popup", actionableCount:10});
                    _popupData.paginationInfo.templateName = _options._popupData.paginationInfo.templateName;
                    _popupData.paginationInfo.templateContainer=_options._popupData.paginationInfo.templateContainer;
                    $(_popupData.paginationInfo.templateContainer).animate({"left":"-=1500", "opacity":0}, 200, function(){
                        _getTemplate(_popupData.paginationInfo.templateName,_popupData, $(_popupData.paginationInfo.templateContainer), function(){
                            $(_popupData.paginationInfo.templateContainer).css("left","1500px");
                            $(_popupData.paginationInfo.templateContainer).animate({"left":"-=1500", "opacity":1},200);
                            $("#js-popup").css("opacity",1);
                            _displayPopup({_popupData:_popupData, _css:{width:_options._css.width, opacity:1, top:180} });
                        });
                    });
                }
            });
        });

        //_populateReferencialSelect(_options);

        //wire up dynamic interaction for the select/option
        if(_options._popupData.popupType === "hierarchical"){
            $("#js-popup_form .js-popup_form_button").css("display","none");
            _getTemplate("/templates/admin/plans/popups/_options.handlebars.html", _options._popupData.primaryOptions, $("#js-popup_form .primaryOptions"), function(){

                $("#js-popup_form .primaryOptions select[name=type]").on("change", function(e){
                    $("#js-popup_form .js-popup_form_button").css("display","block");
                    $("#js-popup_form .secondaryOptions").html("");
                    if($(e.target).val()==="none") {
                        $("#js-popup_form .js-popup_form_button").css("display","none");
                        return;
                    }
                    var _secondaryOptions=[];
                    _options._popupData.fields.forEach(function(field){
                        if(!!field.visibility &&
                            field.visibility.control=="type" &&
                            field.visibility.values.indexOf($(e.target).val())>=0){
                                _secondaryOptions.push(field);
                        }
                    });
                    _getTemplate("/templates/admin/plans/popups/_options.handlebars.html", _secondaryOptions, $("#js-popup_form .secondaryOptions"), function(){
                        $("#js-popup_form .js-popup_form_button").fadeIn();

                    });
                });
            });
        }

        //wire up dynamic bonus amount assignment
        if(_options._popupData.popupType === "bonus_payment"){
            var _amountDetail = _getObjectsByCriteria(_options._popupData.fields, {name:"amounts"})[0];
            _amountDetail.max=_options._popupData.amountDetail.max;
            _amountDetail.maxPercentage=_options._popupData.amountDetail.maxPercentage;
            _amountDetail.total=_options._popupData.amountDetail.total;

            $(".js-percentage_container").each(function(){
                var _rankIndex = (parseInt($(this).attr("data-amount-array-index")));
                var _rankTitle = _data.ranks.entities[_rankIndex].properties.title;
                var _rankID = _data.ranks.entities[_rankIndex].properties.id;
                var _barWidth = $(this).width();
                $(this).find(".js-percentage_label").html(_rankID+", "+_rankTitle+": "+($(this).attr("data-amount-percentage")*100).toFixed(1)+"% <span style='font-size:10px;'>$"+($(this).attr("data-amount-percentage")*_amountDetail.total).toFixed(2)+"</span>");
                $(this).find(".js-percentage_bar").animate({"width":(_barWidth*$(this).attr("data-amount-percentage")).toFixed(0)+"px"},300);
            });

            $(".js-percentage_container").on("mousemove", function(e){
                e.preventDefault();
                var _barWidth = $(this).width();
                var _position = {x: e.pageX - $(this).offset().left, y: e.pageY - $(this).offset().top}
                var _percentage = (_position.x/_barWidth).toFixed(3);
                //_percentage=(Math.round(_percentage)<Math.ceil(_percentage))? Math.floor(_percentage):Math.floor(_percentage)+0.5;
                var _rankIndex = (parseInt($(this).attr("data-amount-array-index")));
                var _rankTitle = _data.ranks.entities[_rankIndex].properties.title;
                var _rankID = _data.ranks.entities[_rankIndex].properties.id;

                _amountDetail.max=_amountDetail.max_values[$(this).attr("data-amount-array-index")];
                if(_percentage>=_amountDetail.max) _percentage=_amountDetail.max;
                $(this).find(".js-percentage_label").html(_rankID+", "+_rankTitle+": ["+(_percentage*100.00).toFixed(1)+"% out of "+(_amountDetail.max*100.00).toFixed(1)+"%] $"+(_percentage*_amountDetail.total).toFixed(2)+"");
                $(this).find(".js-percentage_label").css("color","#ddd");
            });

            $(".js-percentage_container").on("mouseout", function(e){
                e.preventDefault();
                var _rankIndex = (parseInt($(this).attr("data-amount-array-index")));
                var _rankTitle = _data.ranks.entities[_rankIndex].properties.title;
                var _rankID = _data.ranks.entities[_rankIndex].properties.id;
                $(this).find(".js-percentage_label").html(_rankID+", "+_rankTitle+": "+($(this).attr("data-amount-percentage")*100).toFixed(1)+"% <span style='font-size:10px;'>$"+($(this).attr("data-amount-percentage")*_amountDetail.total).toFixed(2)+"</span>");
                $(this).find(".js-percentage_label").css("color","#fff");
            });

            $(".js-percentage_container").on("click", function(e){
                e.preventDefault();
                var _barWidth = $(this).width();
                var _position = {x: e.pageX - $(this).offset().left, y: e.pageY - $(this).offset().top}
                var _percentage = (_position.x/_barWidth).toFixed(2);
                if(_percentage>=_amountDetail.max) _percentage=_amountDetail.max;
                $(this).find(".js-percentage_bar").animate({"width":(_barWidth*_percentage).toFixed(0)+"px"},300);
                $(this).attr("data-amount-percentage",_percentage);
            });

            //input toggle
            $(".js-bonus_payment_mode_percentage").on("click", function(e){
                e.preventDefault();
                $("#bonus_payment_mode_dollar, #bonus_payment_mode_percentage").removeClass("active");
                $("#bonus_payment_mode_dollar").fadeOut(200, function(){
                    $("#bonus_payment_mode_percentage").fadeIn(200);
                    $("#bonus_payment_mode_percentage").addClass("active");
                });
            });

            $(".js-bonus_payment_mode_dollar").on("click", function(e){
                e.preventDefault();
                $("#bonus_payment_mode_dollar, #bonus_payment_mode_percentage").removeClass("active");
                $("#bonus_payment_mode_percentage").fadeOut(200, function(){
                    $("#bonus_payment_mode_dollar").fadeIn(200);
                    $("#bonus_payment_mode_dollar").addClass("active");
                });
            });


            $(".js-update_bonus_payment").on("click", function(e){
                e.preventDefault();
                var _amounts=[];

                if($("#bonus_payment_mode_percentage").hasClass("active")){
                    $(".js-percentage_container").each(function(){
                        _amounts.push(parseFloat($(this).attr("data-amount-percentage")));
                     });
                }else{
                    $("#bonus_payment_mode_dollar input").each(function(){
                        _amounts.push($(this).val().replace(/[^0-9|\.]/g,"")*1.00/100.00);
                    });
                };
                var _postObj = {};
                if($(e.target).parents("form").find("select[name='rank_path_id']").length>0)
                    _postObj.rank_path_id=$(e.target).parents("form").find("select[name='rank_path_id']").val();
                _postObj.amounts = _amounts;

                _ajax({
                    _ajaxType:_options._popupData.method,
                    _url:_options._popupData.href,
                    _postObj: _postObj,
                    _callback:function(data, text){
                        $("#js-screen_mask").click();
                        $("body").css("overflow", "auto");
                        if(typeof _options._callback === "function") _options._callback();
                    }
                });
            });

        }


        if(_options._popupData.deleteOption){
            //delete entities
            $(".js-delete").on("click", function(e){
                e.preventDefault();
                _ajax({
                    _ajaxType:"delete",
                    _url:_options._popupData.href,
                    _callback:function(data, text){
                        $("#js-screen_mask").click();
                        $("body").css("overflow", "auto");

                        if(typeof _options._callback === "function") _options._callback();
                    }
                });
            });
        }

        applyBrowserSpecificRules(); //this fixes the double arrow issue on selects in Firefox <34

        $("#js-popup").fadeIn(100);

    }

    SunStand.Admin.positionIndicator = function (_indicatorObj, _highlightObj){
        _highlightObj.parent().find("a").removeClass("js-active");
        _highlightObj.addClass("js-active");
        _indicatorObj.css("left", (_highlightObj.position().left+(_highlightObj.width()/2)-10)+"px");
        _indicatorObj.css("top", (_highlightObj.position().top+(_highlightObj.height() + 20 ))+"px");
        _indicatorObj.animate({"top":"-=15", "opacity":1}, 300);
        if( _indicatorObj.position().left== (_highlightObj.position().left+(_highlightObj.width()/2)-10)) return;
    }

}(window.SunStand = window.SunStand || {}, jQuery));
});//jQuery



/** end admin utilties **/


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
            if (request.status === 401) {
                window.location = "/#/sign-in";
            }
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
    for(var i=0;i<$(this).file.length;i++){
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
            var _input= _formObj.find("input[name='"+_error.input+"']");
             _formObj.find("input[name='"+_error.input+"']").parents(".form_row").addClass("is_not_valid");
            _formObj.find(".js-error").remove();
            var _html="<span class='js-error'>"+_error.message+"</span>";
            _input.parents(".form_row").prepend(_html);

        break;

    }
}


//get root object (user info, etc.)
function _getRoot(_callback){
    $.ajax({
        type:"get",
        url:"/"
    }).done(function(data, text){
        if(typeof _data === "object" )_data.root = $.extend(true, {}, data);
        else console.log(data);
        if(_data.root.properties){
            var loadingCategories=[
                {
                    url:"/u/profile",
                    name:"profile",
                    data:{}
                },
                {
                    url:"/u/users/"+_data.root.properties.id+"/order_totals",
                    name:"order_totals",
                    data:{}
                },
                {
                    url:"/u/users/"+_data.root.properties.id+"/orders",
                    name:"orders",
                    data:{}
                },
                {
                    url:"/u/users/"+_data.root.properties.id+"/rank_achievements",
                    name:"rank_achievements",
                    data:{}
                }

            ];
            EyeCueLab.JSON.asynchronousLoader(loadingCategories, function(_returnJSONs){
                _data.currentUser=_getObjectsByCriteria(_returnJSONs, {endpoint_name:"profile"})[0].properties;
                _data.currentUser.order_totals=_getObjectsByCriteria(_returnJSONs, {endpoint_name:"order_totals"})[0];
                //_data.currentUser.goals=_getObjectsByCriteria(_returnJSONs, {endpoint_name:"goals"})[0];
                _data.currentUser.rank_achievements=_getObjectsByCriteria(_returnJSONs, {endpoint_name:"rank_achievements"})[0];
                _data.currentUser.orders=_getObjectsByCriteria(_returnJSONs, {endpoint_name:"orders"})[0];
                if(typeof _callback === "function") _callback();

            });
        }
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

    var _evalString="_dataObj";
    var _depth=_path.split("/");
    if(_depth[0]==="") _depth.shift();
    for (var i=_parentLevel;i<0;i++) _depth.pop();

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

    for(var i=_startPage; i<=_endPage; i++){
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


//retrieves Handlebar templates from the _path
//the _dataObj is provides the context/data
//once the template is complied with context, it will assign to the target specified
function _getTemplate(_path, _dataObj, _targetObj, _callback){
    $.ajax({
        url:_path,
        success: function(_source){
            var _template = Handlebars.compile(_source);
            var _html="";
            if(_dataObj != undefined){
                if(_dataObj.constructor==Array){
                    for(var i=0;i<_dataObj.length;i++)
                        _html+=_template(_dataObj[i]);
                }else{
                    _html=_template(_dataObj);
                }
                _targetObj.html(_html);
            }
            if(_callback !== undefined)
                _callback();
        }
    });
}

//Usage:
//  EyeCueLab.JSON.getObjectsByPattern( data,
//                                      {"containsIn(class)":["bonuses", "list"],
//                                       "containsIn(links)":[{rel: "self"}]}
//  )
jQuery(function($){
(function(EyeCueLab, $, undefined){
    EyeCueLab.JSON = {}; //namespace
    EyeCueLab.UX ={};

    EyeCueLab.JSON.getObjectsByPattern = function(_dataObj, _pattern, _results, _searchCriteria){
        if(!_searchCriteria) {
            _searchCriteria = {};

            Object.keys(_pattern).forEach(function(_key){
                if(_key.indexOf("containsIn") >=0) _searchCriteria[(_key.replace(/(containsIn)*(\(|\))*/g,""))]=_pattern[_key];
            });
        }
        if(!_results) _results=[];
        if(typeof _dataObj === "undefined") return;
        Object.keys(_dataObj).forEach(function(_dataKey){
            var breakException = {};
            try{
                Object.keys(_searchCriteria).forEach(function(_searchKey){
                    //check for key match
                    if(!_dataObj[_searchKey]) throw breakException;

                    //check for value match
                    var _matchFound=0;
                    for(var i=0; i<_searchCriteria[_searchKey].length;i++){
                        var _searchCriterion={
                            term:_searchCriteria[_searchKey][i],
                            type:Object.prototype.toString.call(_searchCriteria[_searchKey][i]).replace(/(\[object\s|\])/g,"" )
                        };

                        switch(_searchCriterion.type){
                            case "Object":
                                var _sk = Object.keys(_searchCriterion.term)[0];

                                //loop through the data object if the type is array (e.g. actions)
                                if(Object.prototype.toString.call(_dataObj[_searchKey]).replace(/(\[object\s|\])/g,"" )=="Array"){
                                    for(var i=0;i<_dataObj[_searchKey].length;i++){
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
                                try{
                                    Object.keys(_dataObj[_searchKey]).forEach(function(_k){
                                        if(_dataObj[_searchKey][_k] === _searchCriterion.term) _matchFound+=1;
                                    });
                                }catch(e){
                                    throw breakException;
                                }
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

    EyeCueLab.JSON.asynchronousLoader = function(_endPoints, _callback){
        var _returnJSONs=[];
        var _loadingComplete=0;
        for(var i=0;i<_endPoints.length;i++){
            (function(index){
                $.ajax({
                    type:"get",
                    url:_endPoints[i].url,
                    data:_endPoints[i].data
                }).done(function(data, text){
                    if(typeof _endPoints[index].name !=="undefined") data.endpoint_name=_endPoints[index].name;
                    _returnJSONs.push(data);
                    _loadingComplete = _loadingComplete+1;
                    if(_loadingComplete==_endPoints.length) _callback(_returnJSONs);
                })
            })(i);
        }
    }

    //retrieves Handlebar templates from the _path
    //the _dataObj is provides the context/data
    //once the template is complied with context, it will assign to the target specified
    EyeCueLab.UX.getTemplate = function(_path, _dataObj, _targetObj, _callback){
        $.ajax({
            url:_path,
            success: function(_source){
                var _template = Handlebars.compile(_source);
                var _html="";
                if(typeof _dataObj !== "undefined"){
                    if(_dataObj.constructor==Array){
                        for(var i=0;i<_dataObj.length;i++)
                            _html+=_template(_dataObj[i]);
                    }else{
                        _html=_template(_dataObj);
                    }
                    if(typeof _targetObj !=="undefined") _targetObj.html(_html);
                }

                if(typeof _targetObj == "undefined") _callback(_html);
                if(typeof _callback !== "undefined") _callback();
            }
        });
    }

}(window.EyeCueLab = window.EyeCueLab || {}, jQuery));
});//jQuery

//Shortens strings larger than their respective div with '...'
String.prototype.format_length = function(char_limit){
    if(this && this.length > char_limit){
      return this.substring(0,char_limit).trim() + "..."
    }
    else return this;
}

(function ( $ ) {
  $.fn.progress = function() {
    var percent = this.data("percent");
    this.css("width", percent+"%");
  };
}( jQuery ));
