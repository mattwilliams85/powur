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

	(function(){ //start team dashboard init 
		_data.team=[]; // instantiate team/downlink genealogy object
		_data.team_count_per_page=4; // determine how many thumbnails to show per pagination
		_getTeam(_myID, _data.team, function(){_displayTeam(_data["team"],$("#dashboard_team .section_content.team_info .pagination_content"))});
		
		//put in hooks for team drllldown
		$(document).on("click",".team_thumbnail", function(e){
			_drillDownUserID=$(e.target).parents(".team_thumbnail").attr("alt");
			_thisThumbnail = $(e.target).parents(".team_thumbnail");
			_drillDown({"_type":"team",
						"_mainSectionID":"dashboard_team", 
						"_target":$(e.target),
						"_userID":_drillDownUserID, 
						"_arrowPosition":_thisThumbnail.find("span.expand i").offset().left});

		});


	})();//end team dashboard init

	(function(){
		$(document).on("click", ".pagination_container .nav", function(){
			_pagination_content= $(this).siblings(".pagination_content");

			//todo:check to collapse all active drilldowns

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

	})();


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

			//compile leader info
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
				
				//let's try handlebars!
				_leaderContainerObj = $('#dashboard_team [data-drilldown-level='+_drillDownLevel+']');
				_leaderContainerObj.css("opacity","0");
				// Commenting out the scrollView to remove jank - let's make it a nice-to-have when we can optimize this animation
				// _leaderContainerObj.scrollView(180);
				_leaderContainerObj.animate({height:"+=300px", opacity:1}, _animation_speed);
				_getTemplate("/assets/templates/drilldowns/_team_details.handlebars.html", 
							 _userDetail, 
							 _leaderContainerObj,
							 function(){
							 	//once the basic template is set, now populate the downlink information
							 	//had to do this ascall back due to the asynchronous nature of the calls
							 	//animate up-arrow
							 	_leaderContainerObj.find(".arrow").css("left",(_options._arrowPosition-8));
							 	_leaderContainerObj.find(".arrow").animate({top:"-=20px"}, 1000);
							 	//populate downlink thumbnails
							 	_downlinkContainerObj = $('#dashboard_team [data-drilldown-level='+_drillDownLevel+'] .team_info .pagination_content');
								_tempUserTeam=[];
								_getTeam(_options._userID, _tempUserTeam, function(){_displayTeam(_tempUserTeam, _downlinkContainerObj)});
							 });
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
		_thisThumbnail = _options._target.parents(".team_thumbnail");
		_drillDownDepth = _topLevelSectionObj.children("section").length;

		//fade all other "unfocused" thumbnail out
		for(i=0;i<_currentLevelSectionObj.find(".team_thumbnail").length;i++){
			if(i!=_thisThumbnail.index()){
				_neightborThmbnail = $(_currentLevelSectionObj.find(".team_thumbnail:eq("+i+")"));
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

			_currentLevelSectionObj.find(".team_thumbnail").animate({"opacity":1},_animation_speed);

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


//load the entire team base on the current selected user id 
//optional: save info into a data variable if the variable is defined in param, otherwise display team object
//optional: callback to allow additional operations (e.g. display) post loading
function _getTeam(_userID, _dataStore, _callback){
	$.getJSON("/assets/jsons/users."+_userID+".team.json", function(){
		console.log("... loading user:"+_userID+" team info");
	})
	.done(function(team){
		if(_dataStore != undefined)
			$.each(team, function(counter, val){ _dataStore.push(val);});
		else
			console.log(team);
		if(typeof _callback=="function") _callback();
	})
	.fail(function(){
		console.log("Unable to get user team info")
	});
}



function _displayTeam(_teamObj, _containerObj){
	var _team=[];

	//todo:still need to deal with pagination
	$.each(_teamObj, function(counter, val){
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
		_team.push(_tempObj);
	});

	//naive determine pagination 
	_containerObj.css("width", (_data.global.thumbnail_size.width*_team.length)+"px");
	//remove pagination nav if thumbnail count is less than 5
	if(_team.length<=5) _containerObj.siblings(".nav").fadeOut();


	//populate the team section with members of the team
	_dataObj={};
	_dataObj["downlinks"]=$.extend(true,{}, _team);
	_getTemplate("/assets/templates/_team_thumbnail.handlebars.html", _team, _containerObj);
	//_containerObj.loadTemplate("/assets/templates/team_thumbnail.html", _team);

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

//Utility added to jQuery that allows drilldowns to scroll to view
$.fn.scrollView = function (_offset) {
	if(_offset = undefined) _offset=0;
  return this.each(function (_offset) {
    $('html, body').animate({
      scrollTop: $(this).offset().top-_offset
    }, _animation_speed);
  });
}

