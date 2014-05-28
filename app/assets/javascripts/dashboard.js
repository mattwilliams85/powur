var _myID=100; //current user id
var _data={}; //main data object that contains user profile and genelogy info
var _animation_speed = 500;
var _dashboard;


jQuery(function($){
	$(document).ready(function(){

		//get current user profile and initiate dashboard data
		$.getJSON("/jsons/users."+_myID+".json", function(){
			console.log("... loading user#"+_myID+" profile info");
		})
		.done(function(data){
			_data.profile=$.extend(true, {}, data[0]);
			_dashboard = new Dashboard();
			_dashboard.displayTeam();
			_dashboard.displayQuote();
			setInterval(_dashboard._countdown, 1000);
		});	

		//wire up logout button
		$("#user_logout").on("click", function(e){_formSubmit(e, {}, "/login", "DELETE");});

	});
});


//populate initial data on dashboard screen
function Dashboard(){

	_data.global = {};
	_data.global.thumbnail_size={"width":256,"height":197};
	_data.global.grid_width=32;
	_data.global.total_invitations=5;

	this.displayTeam = displayTeam;
	this.displayQuote = displayQuote;
	this._countdown = _countdown;


	function displayTeam(_tab){
		if(_tab === undefined ) _tab="team.everyone";

		_data.team=[]; // instantiate team/downlink genealogy object
		_data.team_count_per_page=4; // determine how many thumbnails to show per pagination
		_getData(_myID, "team", _data.team, function(){_displayData(_tab, _data["team"],$("#dashboard_team .section_content.team_info .pagination_content"))});
		
		//put in hooks for team drllldown
		$(document).on("click",".js-team_thumbnail", function(e){
			_drillDownUserID=$(e.target).parents(".js-team_thumbnail").attr("alt");
			_thisThumbnail = $(e.target).parents(".js-team_thumbnail");
			_drillDown({"_type":_tab,
						"_mainSectionID":"dashboard_team", 
						"_thumbnailIdentifier":".js-team_thumbnail",
						"_target":$(e.target),
						"_userID":_drillDownUserID, 
						"_arrowPosition":_thisThumbnail.find("span.expand i").offset().left});
		});
		//wire up invitations listing hook
		$(document).on("click", ".js-invites_thumbnail", function(e){
			_thisThumbnail = $(e.target).parents(".js-invites_thumbnail");
			_drillDown({"_type":"invitations",
						"_mainSectionID":$(e.target).parents("section").attr("id"), 
						"_thumbnailIdentifier":".js-invites_thumbnail",
						"_target":$(e.target),
						"_arrowPosition":_thisThumbnail.find("span.expand i").offset().left});
		});
		//wire up invitation detail hooks
		$(document).on("click", ".js-new_invite_thumbnail", function(e){
			_drillDown({"_type":"new_invitations",
						"_mainSectionID":$(this).parents("section.dashboard_section").attr("id"), 
						"_thumbnailIdentifier":".js-new_invite_thumbnail",
						"_target":$(e.target),
						"_arrowPosition":$(this).find("span.expand i").offset().left});
		});	
		//update invitation summary
		_data["invitations"]=[];
		_getData(_myID, "invitations", _data["invitations"], function(){
			_availableInvitations = _data.global.total_invitations - _data.invitations.length;
			$(".js-remaining_invitations").text(_availableInvitations);
			_expiredInvitations=0;
			for(i=0;i<_data.invitations.length;i++) {
			 	_now = new Date();
				_expiration = new Date(	_data.invitations[i].expiration.year,
			 							_data.invitations[i].expiration.month,
			 							_data.invitations[i].expiration.day,
			 							_data.invitations[i].expiration.hour,
										_data.invitations[i].expiration.min,
			 							0);
				_totalSeconds = Math.round((_expiration-_now)/1000);				
				if(_totalSeconds <0) _expiredInvitations++;
			}
			$(".js-expired_invitations").text(_expiredInvitations+" Expired");
		});


		//wire up new invitation submission hook
		$(document).on("click", "#new_promoter_invitation_form .button", function(e){
			console.log($("#new_promoter_invitation_form"))
			_formSubmit(e, $("#new_promoter_invitation_form"), "/invites", "POST");
		});
	}

	//start quote dashboard info
	function displayQuote(_tab){
		if(_tab === undefined ) _tab="quotes";

		_data.quotes =[];
		_data.quote_count_per_page=4;
		_getData(_myID, "quotes", _data.quotes, function(){_displayData(_tab, _data["quotes"],$("#dashboard_quotes .section_content.quotes_info .pagination_content"))});

		//put in hooks for quotes thumbnail
		$(document).on("click",".js-quote_thumbnail", function(e){
			_drillDownUserID=$(e.target).parents(".js-quote_thumbnail").attr("alt");
			_thisThumbnail = $(e.target).parents(".js-quote_thumbnail");
			_drillDown({"_type":_tab,
						"_mainSectionID":"dashboard_quotes", 
						"_thumbnailIdentifier":".js-quote_thumbnail",
						"_target":$(e.target),
						"_userID":_drillDownUserID, 
						"_arrowPosition":_thisThumbnail.find("span.expand i").offset().left});
		});	

		//wire up new quote hooks
		$(document).on("click", ".js-new_quote_thumbnail", function(e){
			_thisThumbnail = $(e.target).parents(".js-new_quote_thumbnail");
			_thisAudience =  $(e.target).parents(".js-new_quote_thumbnail").attr("data-audience");
			_drillDown({"_type":"new_quote",
						"_mainSectionID":$(e.target).parents("section").attr("id"), 
						"_thumbnailIdentifier":".js-new_quote_thumbnail",
						"_target":$(e.target),
						"_audience":_thisAudience, 
						"_arrowPosition":_thisThumbnail.find("span.expand i").offset().left});
		});

	}//end quote dashboard info

	
	//wire up impact metrics hooks
	(function(){
		_data.impact_metrics=[];
		_getData(_myID, "impact_metrics", _data.impact_metrics);

		//put in hooks for kpi thumbnails
		$(document).on("click",".kpi_thumbnail", function(e){
			_thisThumbnail = $(e.target).parents(".kpi_thumbnail");
			_thisKpiType = $(e.target).parents(".kpi_thumbnail").attr("data-kpi-type");

			_drillDown({"_type":"impact_metrics",
						"_mainSectionID":"dashboard_kpis", 
						"_thumbnailIdentifier":".kpi_thumbnail",
						"_target":$(e.target),
						"_kpiType":_thisKpiType, 
						"_arrowPosition":_thisThumbnail.find("span.expand i").offset().left});
		});	
	})();





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

	//wire up the tab hooks
	$(document).on("click", ".tabs li a", function(e){

		e.preventDefault();
		if($(this).attr("class")===undefined) $(this).attr("class", "");
		if ($(this).attr("class").indexOf("active")>=0) return;
		
		_tabSelect({	"_type":$(this).attr("data-tab-type"),
				"_mainSectionID":$(this).parents("section").attr("id"),
				"_target":$(e.target),
		});
	});



	//main function that handles adding different types of drilldowns in different areas of the dashboard
	//the _options has options for the drilldown
	function _drillDown(_options){
		var _abortDrillDown =false;

		_collapseDrillDown(_options);
		if(_abortDrillDown) return;

		switch(_options._type){
			case "team.everyone":
			case "team":
				//determine the next drilldown level
				_drillDownLevel=$("#dashboard_team .drilldown").length+1;

				//compile leader (hero) info
				$.getJSON("/jsons/users."+_options._userID+".json", function(){
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
					_html="<section class=\"drilldown level_"+_drillDownLevel+"\" data-drilldown-level=\""+_drillDownLevel+"\"></section>";
					$("#dashboard_team").append(_html);
					
					_drilldownContainerObj = $('#dashboard_team [data-drilldown-level='+_drillDownLevel+']');
					_drilldownContainerObj.css("opacity","0");
					// _drilldownContainerObj.scrollView(180);
					_drilldownContainerObj.animate({height:"+=300px", opacity:1}, _animation_speed);

					_getTemplate("/templates/drilldowns/_team_details.handlebars.html", 
								 _userDetail, 
								 _drilldownContainerObj,
								 function(){
								 	//once the basic template is set, now populate the downlink information
								 	//had to do this as callback due to the asynchronous nature of the calls
								 	//animate up-arrow
								 	_drilldownContainerObj.find(".arrow").css("left",(_options._arrowPosition-13));
								 	_drilldownContainerObj.find(".arrow").animate({top:"-=20px"}, 1000);
								 	//populate downlink thumbnails
								 	_downlinkContainerObj = $('#dashboard_team [data-drilldown-level='+_drillDownLevel+'] .team_info .pagination_content');
									_tempUserTeam=[];
									_getData(_options._userID, "team", _tempUserTeam, function(){_displayData("team", _tempUserTeam, _downlinkContainerObj)});
								 });
				})
				.fail(function(data){
					_html="<section class=\"drilldown level_"+_drillDownLevel+"\" data-drilldown-level=\""+_drillDownLevel+"\"></section>";
					$("#dashboard_team").append(_html);
					_drilldownContainerObj = $('#dashboard_team [data-drilldown-level='+_drillDownLevel+']');
					_drilldownContainerObj.css("opacity","0");
					// _drilldownContainerObj.scrollView(180);
					_drilldownContainerObj.animate({height:"+=300px", opacity:1}, _animation_speed);	
					_userDetail={};		
					_getTemplate("/templates/drilldowns/_error_state.handlebars.html", {"audience":"promoter"}, _drilldownContainerObj);

				});
			break;
			
		
			case "quotes":
				if(_data.quotes.length==0) return;

				_drillDownLevel=$("#dashboard_quotes .drilldown").length+1;
				_html="<section class=\"drilldown level_"+_drillDownLevel+"\" data-drilldown-level=\""+_drillDownLevel+"\"></section>";
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
				_getTemplate("/templates/drilldowns/_quotes_details.handlebars.html", _userDetail, _drilldownContainerObj, function(){
				 	_drilldownContainerObj.find(".arrow").css("left",(_options._arrowPosition-13));
				 	_drilldownContainerObj.find(".arrow").animate({top:"-=20px"}, 1000);
				});

			break;

			case "new_quote":
				_drillDownLevel=$("#"+_options._mainSectionID+" .drilldown").length+1;
				_html="<section class=\"drilldown level_"+_drillDownLevel+"\" data-drilldown-level=\""+_drillDownLevel+"\"></section>";
				$("#"+_options._mainSectionID).append(_html);
				_drilldownContainerObj = $("#"+_options._mainSectionID+" [data-drilldown-level="+_drillDownLevel+"]");
				_drilldownContainerObj.css("opacity","0");
				_drilldownContainerObj.animate({height:"+=446px", opacity:1}, _animation_speed);	

				_newQuoteDetail={};
				_newQuoteDetail["audience"]=_options._audience;
				_newQuoteDetail["instructions"]="The new quote will be added to your list";

				//populate drilldown
				_getTemplate("/templates/drilldowns/_new_quote.handlebars.html", _newQuoteDetail, _drilldownContainerObj, function(){
				 	_drilldownContainerObj.find(".arrow").css("left",(_options._arrowPosition-13));
				 	_drilldownContainerObj.find(".arrow").animate({top:"-=20px"}, 1000);
				});
			break;

			case "invitations":
				_drillDownLevel=$("#"+_options._mainSectionID+" .drilldown").length+1;
				_html="<section class=\"drilldown level_"+_drillDownLevel+"\" data-drilldown-level=\""+_drillDownLevel+"\"></section>";
				$("#"+_options._mainSectionID).append(_html);

				_drilldownContainerObj = $("#"+_options._mainSectionID+" [data-drilldown-level="+_drillDownLevel+"]");
				_drilldownContainerObj.css("opacity","0");
				_drilldownContainerObj.animate({height:"+=256px", opacity:1}, _animation_speed);	

				_invitationListing=[];
				//get listing array from json
				_getData(_myID, "invitations", _invitationListing, function(){

					//pad the data object with blank invitations
					for(i=_invitationListing.length; i<5; i++) _invitationListing.push({});

					//first place the listing template
					_getTemplate("/templates/drilldowns/new_invitations/_invitations_listing.handlebars.html", {}, _drilldownContainerObj, function(){
						_drilldownContainerObj.find(".arrow").css("left",(_options._arrowPosition-13));
				 		_drilldownContainerObj.find(".arrow").animate({top:"-=20px"}, 1000);

				 		//display thumbnails
				 		_getTemplate("/templates/drilldowns/new_invitations/_invitations_thumbnail.handlebars.html",  _invitationListing, _drilldownContainerObj.find(".drilldown_content_section"), function(){
			 				
			 				//wire up expiration timer
			 				_now = new Date();
			 				$(".js-expiration").each(function(){
			 					var _remainingSeconds, _remainingMinutes, _remainingHours;

			 					_expiration = new Date(	$(this).attr("data-expiration-year"),
			 											$(this).attr("data-expiration-month"),
			 											$(this).attr("data-expiration-day"),
			 											$(this).attr("data-expiration-hour"),
														$(this).attr("data-expiration-minute"),
			 											0);
			 					_totalSeconds = Math.round((_expiration-_now)/1000);
			 					if(_totalSeconds >0){
				 					_remainingHours = Math.floor(_totalSeconds/(60*60));
				 					_totalSeconds = _totalSeconds - _remainingHours*(3600);
				 					_remainingMinutes =  Math.floor(_totalSeconds/(60));
				 					_remainingSeconds = _totalSeconds - _remainingMinutes*(60);
			 						if(_remainingSeconds<10) _remainingSeconds = "0"+_remainingSeconds;
			 						if(_remainingMinutes<10) _remainingMinutes = "0"+_remainingMinutes;
			 						if(_remainingHours<10) _remainingHours = "0"+_remainingHours;
			 						$(this).find(".js-expiration-hours").text(_remainingHours);
				 					$(this).find(".js-expiration-minutes").text(_remainingMinutes);
				 					$(this).find(".js-expiration-seconds").text(_remainingSeconds);
			 					}else{
			 						$(this).html("Expired");
			 					}
			 				});
				 		});
					});

				});
			break;

			case "new_invitations":
				_drillDownLevel=$("#"+_options._mainSectionID+" .drilldown").length+1;
				_html="<section class=\"drilldown level_"+_drillDownLevel+"\" data-drilldown-level=\""+_drillDownLevel+"\"></section>";
				$("#"+_options._mainSectionID).append(_html);

				_drilldownContainerObj = $("#"+_options._mainSectionID+" [data-drilldown-level="+_drillDownLevel+"]");
				_drilldownContainerObj.css("opacity","0");
				_drilldownContainerObj.animate({height:"+=384px", opacity:1}, _animation_speed);

				_newInvitationDetail = {};
				_newInvitationDetail.invitationType="Existing";
				if(_thisThumbnail.attr("class").indexOf("js-empty_seat")>=0) _newInvitationDetail.invitationType="New";

				_getTemplate("/templates/drilldowns/new_invitations/_invitations_detail.handlebars.html", _newInvitationDetail, _drilldownContainerObj, function(){
					_drilldownContainerObj.find(".arrow").css("left",(_options._arrowPosition-13));
				 	_drilldownContainerObj.find(".arrow").animate({top:"-=20px"}, 1000);
				});

			break;


			case "impact_metrics":
				_drillDownLevel=$("#"+_options._mainSectionID+" .drilldown").length+1;
				_html="<section class=\"drilldown level_"+_drillDownLevel+"\" data-drilldown-level=\""+_drillDownLevel+"\"></section>";
				$("#"+_options._mainSectionID).append(_html);
				_drilldownContainerObj = $("#"+_options._mainSectionID+" [data-drilldown-level="+_drillDownLevel+"]");
				_drilldownContainerObj.css("opacity","0");
				_drilldownContainerObj.animate({height:"+=446px", opacity:1}, _animation_speed);	
				var _templatePath;
				var _impactMetricsDetail = {};

				//todo: inject context/data under each template
				switch(_options._kpiType){
					case "type1":
						_templatePath="/templates/drilldowns/impact_metrics/_kpi_environment_details.handlebars.html";
					break;
					case "type2":
						_templatePath="/templates/drilldowns/impact_metrics/_kpi_customer_details.handlebars.html";
					break;
					case "type3":
						_templatePath="/templates/drilldowns/impact_metrics/_kpi_environment_details.handlebars.html";
					break;
					case "type4":
						_templatePath="/templates/drilldowns/impact_metrics/_kpi_environment_details.handlebars.html";
					break;
					case "type5":
						_templatePath="/templates/drilldowns/impact_metrics/_kpi_environment_details.handlebars.html";
					break;
				}

				_getTemplate(_templatePath, _impactMetricsDetail, _drilldownContainerObj, function(){
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
				if(i!=_thisThumbnail.index(_options._thumbnailIdentifier)){
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
				clearTimeout();
				return;
			}

			_thisThumbnail.animate({"opacity":1}, 1000);
			_thisThumbnail.find("span.expand i").removeClass("fa-angle-down");
			_thisThumbnail.find("span.expand i").addClass("fa-angle-up");
		}
	}



	function _tabSelect(_options){
		var _tabData;
		console.log(_options._mainSectionID);
		console.log(_options._type);
		/*_getData(_myID,_options._type, _tabData, function(){
			_displayData(_options._type, _tabData)
		});*/
	}



	//load the user dashboard basic info base on the current selected user id 
	//_dataType dictates which endpoint to hit
	//optional: save info into a data variable if the variable is defined in param, otherwise display data object
	//optional: callback to allow additional operations (e.g. display) post loading
	function _getData(_userID, _dataType, _dataStore, _callback){
		var _endPoint="";
		switch(_dataType){
			case "team.everyone":
			case "team":
				_endPoint="/jsons/users."+_userID+".team.json";
			break;
			
			case "quotes":
				_endPoint="/jsons/users."+_userID+".quotes.json";
			break;

			case "invitations":
				_endPoint="/jsons/users."+_userID+".invitations.json";

			break;

		}

		$.getJSON(_endPoint, function(){
			console.log("... loading user:"+_userID+" "+_dataType+" info");
		})
		.done(function(_d){
			if(typeof _dataStore !== "undefined")
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
	function _displayData(_dataType, _dataObj, _containerObj, _callback){
		var _processedJSON=[];
		var _templatePath="";

		switch(_dataType){
			case "team.everyone":
			case "team":
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
				_templatePath="/templates/_team_thumbnail.handlebars.html";
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
					_tempObj["current_status"]=Object.keys(val.quote_status)[Object.keys(val.quote_status).length-1];
					_processedJSON.push(_tempObj);
				});
				_templatePath="/templates/_quote_thumbnail.handlebars.html";
			break;

		}
		//naive determine pagination 
		_containerObj.css("width", (_data.global.thumbnail_size.width*_processedJSON.length)+"px");

		//remove pagination nav if thumbnail count is less than 5
		if(_processedJSON.length<=5) _containerObj.siblings(".nav").fadeOut();

		//populate the team section with appropriate _templatePath, data, and container
		_getTemplate(_templatePath, _processedJSON, _containerObj);

		if(_callback !== undefined) _callback();
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
				if(_callback !== undefined)
					_callback();
			}
		});
	}

	//start timeout function
	function _countdown(){
		var _remainingSeconds, _remainingMinutes, _remainingHours;
		$(".js-expiration-seconds").each(function(){
			_remainingSeconds = $(this).text()*1-1;
			if(_remainingSeconds<1){
				_remainingMinutes=$(this).siblings(".js-expiration-minutes").text()-1;
				if(_remainingMinutes<1){
					_remainingHours = $(this).siblings(".js-expiration-hours").text()-1;
					if(_remainingHours<1){
						$(this).html("Expired");
						return;
					}
					_remainingMinutes = 60;
					_remainingSeconds =60;
				}
				_remainingSeconds=60;
			}
			if(_remainingSeconds<10) _remainingSeconds = "0"+_remainingSeconds;
			if(_remainingMinutes<10) _remainingMinutes = "0"+_remainingMinutes;
			if(_remainingHours<10) _remainingHours = "0"+_remainingHours;

			$(".js-expiration-seconds").text(_remainingSeconds);
			$(".js-expiration-minutes").text(_remainingMinutes);
			$(".js-expiration-hours").text(_remainingHours);
		});
	}


}// end Dashboard class








