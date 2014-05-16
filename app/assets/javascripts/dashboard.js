var _myID=100; //current user id
var _data={}; //main data object that contains user profile and genelogy info
var _animation_speed = 500;




$(document).ready(function(){


	//get current user profile and initiate dashboard data
	$.getJSON("/assets/jsons/users."+_myID+".json", function(){
		console.log("... loading user#"+_myID+" profile info");
	})
	.done(function(data){
		_data.profile=$.extend(true, {}, data[0]);
		_dashboardInit();
	});		
});



//populate initial data on dashboard screen
function _dashboardInit(){
	_data.global = {};
	_data.global.thumbnail_size={"width":256,"height":197};
	_data.global.grid_width=32;

	//start team dashboard info 
	(function(){
		_data.team=[]; // instantiate team/downlink genealogy object
		_data.team_count_per_page=4; // determine how many thumbnails to show per pagination
		_getData(_myID, "team", _data.team, function(){_displayData("team", _data["team"],$("#dashboard_team .section_content.team_info .pagination_content"))});
		
		//put in hooks for team drllldown
		$(document).on("click",".js-team_thumbnail", function(e){
			_drillDownUserID=$(e.target).parents(".js-team_thumbnail").attr("alt");
			_thisThumbnail = $(e.target).parents(".js-team_thumbnail");
			_drillDown({"_type":"team",
						"_mainSectionID":"dashboard_team", 
						"_thumbnailIdentifier":".js-team_thumbnail",
						"_target":$(e.target),
						"_userID":_drillDownUserID, 
						"_arrowPosition":_thisThumbnail.find("span.expand i").offset().left});
		});
	})();//end team dashboard info

	//start quote dashboard info
	(function(){
		_data.quotes =[];
		_data.quote_count_per_page=4;
		_getData(_myID, "quotes", _data.quotes, function(){_displayData("quotes", _data["quotes"],$("#dashboard_quotes .section_content.quotes_info .pagination_content"))});

		//put in hooks for quotes thumbnail
		$(document).on("click",".js-quote_thumbnail", function(e){
			_drillDownUserID=$(e.target).parents(".js-quote_thumbnail").attr("alt");
			_thisThumbnail = $(e.target).parents(".js-quote_thumbnail");
			_drillDown({"_type":"quotes",
						"_mainSectionID":"dashboard_quotes", 
						"_thumbnailIdentifier":".js-quote_thumbnail",
						"_target":$(e.target),
						"_userID":_drillDownUserID, 
						"_arrowPosition":_thisThumbnail.find("span.expand i").offset().left});
		});	
	})();//end quote dashboard info

	
	//wire up invitation hooks
		$(document).on("click", ".new_thumbnail", function(e){
			_thisThumbnail = $(e.target).parents(".new_thumbnail");
			_thisAudience =  $(e.target).parents(".new_thumbnail").attr("data-audience");
			_drillDown({"_type":"invitations",
						"_mainSectionID":$(e.target).parents("section").attr("id"), 
						"_thumbnailIdentifier":".new_thumbnail",
						"_target":$(e.target),
						"_audience":_thisAudience, 
						"_arrowPosition":_thisThumbnail.find("span.expand i").offset().left});
		});


	//wire up the pagination hooks
	$(document).on("click", ".pagination_container .nav", function(){
		_pagination_content= $(this).siblings(".pagination_content");

		//animate the content
		_pagination_width=_data.team_count_per_page*_data.global.thumbnail_size.width;

		//return if it's already being animated
		if( _pagination_content.filter(':animated').length>0) return;
		if($(this).attr("class").indexOf("left")>=0){
			if(_pagination_content.css("left")=="0px") return;
			_pagination_content.animate({"left":"+="+_pagination_width+"px"});
		}else{
			if((parseInt(_pagination_content.css("width"))+parseInt(_pagination_content.css("left"))-_pagination_width)<=0) return;
			_pagination_content.animate({"left":"-="+_pagination_width+"px"});
		}
	});


}


//main function that handles adding different types of drilldowns in different areas of the dashboard
//the _options has options for the drilldown
function _drillDown(_options){
	var _abortDrillDown =false;

	_collapseDrillDown(_options);
	if(_abortDrillDown) return;

	switch(_options._type){
		case "team":
			//determine the next drilldown level
			_drillDownLevel=$("#dashboard_team .drilldown").length+1;

			//compile leader (hero) info
			$.getJSON("/assets/jsons/users."+_options._userID+".json", function(){
				console.log("... loading user#"+_options._userID+" profile info");
			})
			.done(function(data){
				//prepare leader info
				_userDetail={};
				_userDetail["name"] = data[0].info.first_name+" "+data[0].info.last_name;
				_userDetail["profile_image"] = data[0].info.profile_image;
				_userDetail["email"] = data[0].info.email;
				_userDetail["phone"] = data[0].info.phone;
				_userDetail["generation"] = _drillDownLevel;
				for(key in data[0].rank[data[0].rank.length-1]) _userDetail["rank"] = key;

				//add new team drilldown basic template layout with leader info
				_html="<section class=\"drilldown\" data-drilldown-level=\""+_drillDownLevel+"\"></section>";
				$("#dashboard_team").append(_html);
				
				_drilldownContainerObj = $('#dashboard_team [data-drilldown-level='+_drillDownLevel+']');
				_drilldownContainerObj.css("opacity","0");
				// _drilldownContainerObj.scrollView(180);
				_drilldownContainerObj.animate({height:"+=300px", opacity:1}, _animation_speed);

				_getTemplate("/assets/templates/drilldowns/_team_details.handlebars.html", 
							 _userDetail, 
							 _drilldownContainerObj,
							 function(){
							 	//once the basic template is set, now populate the downlink information
							 	//had to do this ascall back due to the asynchronous nature of the calls
							 	//animate up-arrow
							 	_drilldownContainerObj.find(".arrow").css("left",(_options._arrowPosition-13));
							 	_drilldownContainerObj.find(".arrow").animate({top:"-=20px"}, 1000);
							 	//populate downlink thumbnails
							 	_downlinkContainerObj = $('#dashboard_team [data-drilldown-level='+_drillDownLevel+'] .team_info .pagination_content');
								_tempUserTeam=[];
								_getData(_options._userID, "team", _tempUserTeam, function(){_displayData("team", _tempUserTeam, _downlinkContainerObj)});
							 });
			});
		break;
		
		case "quotes":
			if(_data.quotes.length==0) return;

			_drillDownLevel=$("#dashboard_quotes .drilldown").length+1;
			_html="<section class=\"drilldown\" data-drilldown-level=\""+_drillDownLevel+"\"></section>";
			$("#dashboard_quotes").append(_html);
			_drilldownContainerObj = $('#dashboard_quotes [data-drilldown-level='+_drillDownLevel+']');
			_drilldownContainerObj.css("opacity","0");
			_drilldownContainerObj.animate({height:"+=446px", opacity:1}, _animation_speed);	

			//retrieve info from _data.quotes for the quote
			_userDetail={};
			for(i=0;i<_data.quotes.length;i++)
				if(_data.quotes[i].info.id==_options._userID)
					_userDetail=$.extend(true, {}, _data.quotes[i]);
			
			//populate drilldown
			_getTemplate("/assets/templates/drilldowns/_quotes_details.handlebars.html", _userDetail, _drilldownContainerObj, function(){
			 	_drilldownContainerObj.find(".arrow").css("left",(_options._arrowPosition-13));
			 	_drilldownContainerObj.find(".arrow").animate({top:"-=20px"}, 1000);
			});

		break;

		case "invitations":

			_drillDownLevel=$("#"+_options._mainSectionID+" .drilldown").length+1;
			_html="<section class=\"drilldown\" data-drilldown-level=\""+_drillDownLevel+"\"></section>";
			$("#"+_options._mainSectionID).append(_html);
			_drilldownContainerObj = $("#"+_options._mainSectionID+" [data-drilldown-level="+_drillDownLevel+"]");
			_drilldownContainerObj.css("opacity","0");
			_drilldownContainerObj.animate({height:"+=446px", opacity:1}, _animation_speed);	

			//retrieve info from _data.quotes for the quote			
			_invitationDetail={};
			_invitationDetail["audience"]=_options._audience;
			if(_options._audience=="quote") _invitationDetail["instructions"]="The new quote will be added to your list";
			else _invitationDetail["instructions"]="We will be sending them an onboarding link on yoru behalf.  ";

			//populate drilldown
			_getTemplate("/assets/templates/drilldowns/_invitations.handlebars.html", _invitationDetail, _drilldownContainerObj, function(){
			 	_drilldownContainerObj.find(".arrow").css("left",(_options._arrowPosition-13));
			 	_drilldownContainerObj.find(".arrow").animate({top:"-=20px"}, 1000);
			});

		break;

		default:
			console.log("Drilldown type not found");
		break;
	}

	//sub function of the drilldown that checks for the need to collapse children drilldowns
	function _collapseDrillDown(_options){
		//set up context for what's being clicked
		_currentLevelSectionObj=_options._target.closest("section"); 				
		_drillDownFocusLevel=_currentLevelSectionObj.attr("data-drilldown-level")*1; 					
		_topLevelSectionObj = (_drillDownFocusLevel*1>0)? _topLevelSectionObj = _currentLevelSectionObj.parents("section"):_currentLevelSectionObj;	
		_thisThumbnail = _options._target.parents(_options._thumbnailIdentifier);//use class to identify (e.g. team_thumbnail, quote_thumbnail, etc.)
		_drillDownDepth = _topLevelSectionObj.children("section").length;

		//fade all other "unfocused" thumbnail out
		for(i=0;i<_currentLevelSectionObj.find(_options._thumbnailIdentifier).length;i++){
			if(i!=_thisThumbnail.index()){
				_neightborThmbnail = $(_currentLevelSectionObj.find(_options._thumbnailIdentifier+":eq("+i+")"));
				_neightborThmbnail.animate({"opacity":".3"}, 1000);
				_neightborThmbnail.find("span.expand i").removeClass("fa-angle-up");
				_neightborThmbnail.find("span.expand i").addClass("fa-angle-down");
			}
		}

		//close any level after the current level
		for(i=_drillDownDepth;i>_drillDownFocusLevel;i--){
				_topLevelSectionObj.find("[data-drilldown-level="+i+"]").remove();
		}

		//if checking on self collapse everything
		if(_thisThumbnail.find("span.expand i").attr("class").indexOf("fa-angle-up")>=0){
			_thisThumbnail.find("span.expand i").removeClass("fa-angle-up");
			_thisThumbnail.find("span.expand i").addClass("fa-angle-down");
			_abortDrillDown=true;

			_currentLevelSectionObj.find(_options._thumbnailIdentifier).animate({"opacity":1},_animation_speed);

			return;
		}

		_thisThumbnail.animate({"opacity":1}, 1000);
		_thisThumbnail.find("span.expand i").removeClass("fa-angle-down");
		_thisThumbnail.find("span.expand i").addClass("fa-angle-up");
	}
}


//load specific user profile base on the current selected user id
//optional: save info into a data variable if the variable is defined in param, otherwise profile object
//optional: callback to allow additional operations (e.g. display) post loading
function _getUserInfo(_userID, _dataStore, _callback){
	$.getJSON("/assets/jsons/users."+_userID+".json", function(){
		console.log("... loading user#"+_userID+" profile info");
	})
	.done(function(data){
		if(_dataStore != undefined){
			_dataStore=jQuery.extend(true, {}, data[0]);
		}
		else{console.log(data[0]);}

		if(typeof _callback=="function") _callback();
	})
	.fail(function(){
		console.log("Unable to get user profile info")
	});
}


//load the user dashboard basic info base on the current selected user id 
//_dataType dictates which endpoint to hit
//optional: save info into a data variable if the variable is defined in param, otherwise display data object
//optional: callback to allow additional operations (e.g. display) post loading
function _getData(_userID, _dataType, _dataStore, _callback){
	var _endPoint="";
	switch(_dataType){
		case "team":
			_endPoint="/assets/jsons/users."+_userID+".team.json"
		break;
		
		case "quotes":
			_endPoint="/assets/jsons/users."+_userID+".quotes.json"
		break;
	}

	$.getJSON(_endPoint, function(){
		console.log("... loading user:"+_userID+" "+_dataType+" info");
	})
	.done(function(_d){
		if(_dataStore != undefined)
			$.each(_d, function(counter, val){ _dataStore.push(val);});
		else
			console.log(_d);
		if(typeof _callback=="function") _callback();
	})
	.fail(function(){
		console.log("Unable to get user "+_dataType+" info")
	});
}


//_displayData function acts as middle layer btween JSON from database and the final template output
//it prepares only necessary information and allows a place to add additional logic for template output
//_dataType dictates what type of JSON is being processed
//_dataObj is the actual JSON from the API endpoint
//_containerObj is the DOM object that the final rendered template will be appending to
function _displayData(_dataType, _dataObj, _containerObj){
	var _processedJSON=[];
	var _templatePath="";

	switch(_dataType){
		case "team":
			console.log(_containerObj);
			$.each(_dataObj, function(counter, val){
				_tempObj={};
				_tempObj["bindingObj"]=val.info.id+"_thumbnail";
				_tempObj["id"]=val.info.id;
				_tempObj["profile_image"] = val.info.profile_image;
				_tempObj["first_name"]= val.info.first_name;
				_tempObj["name"]= val.info.first_name+" "+val.info.last_name;
				_tempObj["phone"]= val.info.phone;
				_tempObj["email"]= val.info.email;
				for(key in val.rank[val.rank.length-1]) _tempObj["rank"] = key;
				_tempObj["quotes_approved"]= val.customers.quotes_approved.length;
				_tempObj["panels_installed"]= val.customers.panels_installed.length;
				_tempObj["team_size"]= val.genealogy.downlinks.length;
				_processedJSON.push(_tempObj);
			});
			_templatePath="/assets/templates/_team_thumbnail.handlebars.html";
		break;

		case "quotes":
			$.each(_dataObj, function(counter, val){
				_tempObj={};
				_tempObj["bindingObj"]=val.info.id+"_thumbnail";
				_tempObj["id"]=val.info.id;
				_tempObj["first_name"]= val.info.first_name;
				_tempObj["last_name"]= val.info.last_name;
				_tempObj["name"]= val.info.first_name+" "+val.info.last_name;
				_tempObj["phone"]= val.info.phone;
				_tempObj["email"]= val.info.email;
				_tempObj["address"]= val.info.address;
				_tempObj["utility_info"]=val.utility_info;
				_tempObj["quote_status"]=val.quote_status;
				_processedJSON.push(_tempObj);
			});
			_templatePath="/assets/templates/_quote_thumbnail.handlebars.html";
		break;

	}
	//naive determine pagination 
	_containerObj.css("width", (_data.global.thumbnail_size.width*_processedJSON.length)+"px");

	//remove pagination nav if thumbnail count is less than 5
	if(_processedJSON.length<=5) _containerObj.siblings(".nav").fadeOut();

	//populate the team section with appropriate _templatePath, data, and container
	_getTemplate(_templatePath, _processedJSON, _containerObj);
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
					for(i=0;i<_dataObj.length;i++)
						_html+=_template(_dataObj[i]);
				}else{
					_html=_template(_dataObj);
				}
				_targetObj.html(_html);
			}
			if(_callback != undefined)
				_callback();
		}
	});
}




