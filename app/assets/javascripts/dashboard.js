var _myID=0; //current user id
var _data={}; //main data object that contains user profile and genelogy info
var _animation_speed = 300;
var _dashboard;

$(window).bind('page:change', function() {
  initPage();
});


function initPage(){
	_data.root={};

	//get current user profile and initiate dashboard data
	_getRoot(function(){
		$(".js-user_first_name").text(_data.root.properties.first_name );
		_myID = _data.root.properties.id;
		_dashboard = new Dashboard();
		_dashboard.displayGoals();
		_dashboard.displayTeam();
		_dashboard.displayQuotes();
		_dashboard.displayKPIs();
		if(_data.currentUser.thumb_image_url) $("#js-user_profile_image").attr("src", _data.currentUser.thumb_image_url);
		setInterval(_dashboard._countdown, 1000);			
	});

	//wire up logout button
	$("#user_logout").on("click", function(e){_formSubmit(e, {}, "/login", "delete", function(data, text){
	});});

	//admin toolbar
	$('.hover-box').hover(function(e){
		$('.js-admin_tab').stop();
		e.stopPropagation()
		if($('.js-admin_tab').is(':animated')) return;
		$('.js-admin_tab').animate({
			"left":"-70px"
		}, 300);

	});

	$( ".hover-box" ).mouseleave(function(e) {
		$('.js-admin_tab').stop();
		e.stopPropagation()
		$('.js-admin_tab').animate({
			"left":"-140px"
		},300);

	});

};


//populate initial data on dashboard screen
function Dashboard(){
	_data.global = {};
	_data.global.thumbnail_size={"width":252,"height":197};
	_data.global.grid_width=32;
	_data.global.total_invitations=5;

	this.displayTeam = displayTeam;
	this.displayQuotes = displayQuotes;
	this.displayGoals = displayGoals;
	this.displayKPIs = displayKPIs;
	this._countdown = _countdown;


	function displayKPIs(){
		var kpi={
			environment:{
				tab:{
					value:721.34,
					label:"CO2 Tons Saved"
				}
			},
			leads:{
				tab:{
					value:78,
					label:"Quotes"
				}
			},
			earnings:{
				tab:{
					value:"$2,182.67",
					label:"Total Earnings"
				}
			},
			team_members:{
				tab:{
					value:327,
					label:"In Your Genealogy"
				}
			}

		}

		Object.keys(kpi).forEach(function(key){
			$(".kpi_thumbnail[data-kpi-type="+key+"] .kpi_value span").html(kpi[key].tab.value)
			$(".kpi_thumbnail[data-kpi-type="+key+"] .kpi_label").html(kpi[key].tab.label)

		});	
		
		//adjust font width for metrics
		$(".kpi_thumbnail h1").each(function(){
			var _width=$(this).find("span:first").width()+174;
			var _newWidth = Math.floor(220*60/_width);
			$(this).css("font-size", _newWidth+"pt");
		});

	}	

	function displayGoals(path){
		return;
		// hook up the control for changing paths
		$("#pay_period_goal_path").on("change", function(e){
			$("#goal_meters .labels, #goal_meters .highlight").html("");
				displayGoals($(this).val());
		});

		var goals={};
		goals.sales={
			personal:{
				min:0,
				max:0,
				current:0,
			},
			group:{
				min:0,
				max:0,
				current:0
			}
		}
		//populate path dropdown
		if(typeof path === "undefined"){
			goals.paths=EyeCueLab.JSON.getObjectsByPattern(_data.currentUser.goals, {"containsIn(class)":["ranks", "list"]})[0].properties.paths;
			$("#pay_period_goal_path").html("");
			goals.paths.forEach(function(path){
				$("#pay_period_goal_path").append("<option value="+path+">Path: "+path+"</option>");
			});
		}


		goals.rank={
			pay_as_rank:_data.currentUser.goals.properties.pay_as_rank,
			next_rank:_data.currentUser.goals.properties.pay_as_rank+1
		}

		goals.next_rank=EyeCueLab.JSON.getObjectsByPattern(_data.currentUser.goals, {"containsIn(class)":["ranks", "list"]})[0].entities[goals.rank.next_rank-1];
		if(goals.rank.pay_as_rank>1){
			goals.current_rank=EyeCueLab.JSON.getObjectsByPattern(_data.currentUser.goals, {"containsIn(class)":["ranks", "list"]})[0].entities[goals.rank.pay_as_rank-1];
		}

		goals.next_rank.qualifications=_getObjectsByCriteria(goals.next_rank, {path:$("#pay_period_goal_path").val()});
		
		var displayPrimaryProduct={
			id:1, /* this is hardcoded for the sunrun solar item, this what will be displayed in the bars */
			name:"SunRun Solar Item"
		}


		//setup current personal and group sales total
		var sales = _getObjectsByCriteria(_data.currentUser.order_totals, {product:displayPrimaryProduct.name})[0];
		if(typeof sales !=="undefined"){
			goals.sales.personal.current=sales.personal;
			goals.sales.group.current=sales.group;
		}
		//setup the max
		goals.next_rank.qualifications.forEach(function(qualification){
			if(qualification.product_id==displayPrimaryProduct.id){
				$("#dashboard_personal_goals .product").html("Product: "+qualification.product);
				switch(qualification.type_display.toLowerCase()){
					case "personal sales":
						goals.sales.personal.max=qualification.quantity;
						$("#dashboard_personal_goals .personal_sales").html("Personal "+qualification.time_period+" sales");
						if(goals.sales.personal.current>goals.sales.personal.max) goals.sales.personal.current = goals.sales.personal.max
					break;

					case "group sales":
						goals.sales.group.max=qualification.quantity;
						$("#dashboard_personal_goals .group_sales").html("Group "+qualification.time_period+" sales");
						if(goals.sales.group.current>goals.sales.group.max) goals.sales.group.current = goals.sales.group.max
					break;
				}
			}
		});
		
		Object.keys(goals.sales).forEach(function(_key){
			var _section_width=$("#"+_key+"_sales .labels").width();
			var notches={};
			notches.total=goals.sales[_key].max-goals.sales[_key].min;
			notches.width=Math.ceil(_section_width/notches.total);
			notches.min=goals.sales[_key].min;
			notches.max=goals.sales[_key].max-1;
			notches.current = goals.sales[_key].current;
			for(i=notches.min; i<=notches.max;i++){
				var _counter = (i<10)?"0"+i:i;
				var _maxCounter = (notches.max+1<10)?"0"+(notches.max+1):(notches.max+1);
				_html=	"<div class='notch' style='width:"+((1/notches.total)*100)+"%;'>";
				_html+=	"<span>"+_counter+"</span><div></div>";
				if(i<notches.max)_html+=	"</div>";
				else _html+= "<span class='last_notch'>"+_maxCounter+"</span><div class='last_notch'></div></div>"
				$("#"+_key+"_sales .labels").append(_html);
			}
			$("#"+_key+"_sales .highlight").animate({width:(((notches.current-notches.min)/notches.total*100)+"%")}, 1000)
		});
		$("#dashboard_personal_goals .next_rank").html("Next Rank: "+goals.rank.next_rank);

	}

	function displayTeam(_tab){
		if(_tab === undefined ) _tab="team.everyone";

		if(typeof _data.team_search === "undefined" )_data.team_search="";
		if(typeof _data.team_metric === "undefined" )_data.team_metric="quotes";
		if(typeof _data.team_period === "undefined" )_data.team_period="lifetime";

		_data.team=[]; // instantiate team/downlink genealogy object
		_data.team_count_per_page=4; // determine how many thumbnails to show per pagination
		_data._team=[];

		//wire up invitations listing hook
		$(".js-invites_thumbnail").on("click", function(e){
			e.preventDefault();
			_thisThumbnail = $(e.target).parents(".js-invites_thumbnail");
			_drillDown({"_type":"invitations",
						"_mainSectionID":$(e.target).parents("section").attr("id"), 
						"_thumbnailIdentifier":".js-invites_thumbnail",
						"_target":$(e.target),
						"_arrowPosition":_thisThumbnail.find("span.expand i").offset().left});
		});

		_ajax({
			_ajaxType:"get",
			_url:"/u/users/",
			_postObj:{
				"performance[metric]":_data.team_metric,
				"performance[period]":_data.team_period,
				search:_data.team_search
			},
			_callback:function(data, text){
				console.log(data)
				if(data.entities.length<=0) return;
				var _containerObj = $("#dashboard_team .section_content.team_info .pagination_content");
				_data.team=data;
				_containerObj.siblings(".nav").css("display","none");
				_containerObj.css("left","0")
				_containerObj.css("width", (_data.global.thumbnail_size.width*data.entities.length)+"px");
				if(data.entities.length>=4) _containerObj.siblings(".nav").fadeIn();

				_containerObj.html("");
				_data.team.entities.forEach(function(member){
					_ajax({
						_ajaxType:"get",
						_url:"/u/users/"+member.properties.id+"/downline",
						_callback:function(data, text){
							member.properties.downline_count = data.entities.length;
							EyeCueLab.UX.getTemplate("/templates/_team_thumbnail.handlebars.html", member, undefined, function(html){
								_containerObj.append(html);
							});
						}
					});
				});
				
				$("#team_search").unbind();
				$("#performance_metric").unbind();
				$("#performance_period").unbind();

				$("#team_search").on("keyup", function(e){
					switch(e.keyCode){
						case 13:
							if($(e.target).val().length<3 && $(e.target).val().length>0) return;
				    		if($(e.target).val().length>=3 || $(e.target).val().length==0){
								$("#dashboard_team > section").remove();
				    			_data.team_search=$(e.target).val();
								_collapseTeam();
								displayTeam();
				    		}
						break;
					}
				});

				$("#performance_period, #performance_metric").on("change", function(e){
					e.preventDefault();
					_data[$(this).attr("name")]=$(this).val();
					$("#dashboard_team > section").remove();
					_collapseTeam();
					displayTeam();
				});
			}
		});
		_updateInvitationSummary();
	}

	//start quote dashboard info
	function displayQuotes(_tab){
		if(_tab === undefined ) _tab="quotes";

		_data.quotes =[];
		_data.quote_count_per_page=4;
		if(typeof _data.quote_sort === undefined )_data.quote_sort="created";
		if(typeof _data.quote_search === undefined )_data.quote_search="";
		_ajax({
			_ajaxType:"get",
			_url:"/u/quotes",
			_postObj:{
				search:_data.quote_search,
				sort:_data.quote_sort
			},
			_callback:function(data, type){
				_data.quotes=data;
				$(".js-new_quote_thumbnail").unbind();
				//wire up new leads hooks
				$(".js-new_quote_thumbnail").on("click", function(e){
					e.preventDefault();
					_thisThumbnail = $(e.target).parents(".js-new_quote_thumbnail");
					_thisAudience =  $(e.target).parents(".js-new_quote_thumbnail").attr("data-audience");
					_drillDown({"_type":"new_quote",
								"_mainSectionID":$(e.target).parents("section").attr("id"), 
								"_thumbnailIdentifier":".js-new_quote_thumbnail",
								"_target":$(e.target),
								"_audience":_thisAudience, 
								"_arrowPosition":_thisThumbnail.find("span.expand i").offset().left});
				});
				if(_data.quotes.entities.length<=0) return;
				var _containerObj = $("#dashboard_quotes .section_content.quotes_info .pagination_content");
				_containerObj.html("");
				if(_data.quotes.entities.length>4) _containerObj.siblings(".nav").fadeIn();
				_containerObj.css("width", (_data.global.thumbnail_size.width*_data.quotes.entities.length)+"px");
				var _displayData= data.entities;
				

				EyeCueLab.UX.getTemplate("/templates/_quote_thumbnail.handlebars.html", data.entities, _containerObj, function(){

					$("#quote_sort").unbind();
					$("#quote_search").unbind();
					$(".js-quote_thumbnail").unbind();

					//put in sort filter
					$("#quote_sort").on("change", function(e){
						_data.quote_sort=$(this).val();
						displayQuotes();
					});


					$("#quote_search").on("keyup", function(e){
						switch(e.keyCode){
							case 13:
								if($(e.target).val().length<3 && $(e.target).val().length>0) return;
					    		if($(e.target).val().length>=3 || $(e.target).val().length==0){
									$("#dashboard_quotes > section").remove();
					    			_data.quote_search=$(e.target).val();
									displayQuotes()
					    		}
							break;
						}
					});

					//put in hooks for quotes thumbnail
					$(".js-quote_thumbnail").on("click", function(e){
						e.preventDefault();
						_drillDownUserID=$(e.target).parents(".js-quote_thumbnail").attr("alt");
						_thisThumbnail = $(e.target).parents(".js-quote_thumbnail");
						_drillDown({"_type":_tab,
									"_mainSectionID":"dashboard_quotes", 
									"_thumbnailIdentifier":".js-quote_thumbnail",
									"_target":$(e.target),
									"_userID":_drillDownUserID, 
									"_arrowPosition":_thisThumbnail.find(".expand .fa").offset().left});
					});	



				});

			}
		});

	}//end quote dashboard info

	//wire up impact metrics hooks
	(function(){
		_data.impact_metrics=[];
		_getData(_myID, "impact_metrics", _data.impact_metrics);

		//put in hooks for kpi thumbnails
		$(document).on("click",".kpi_thumbnail", function(e){
			e.preventDefault();
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
	$(document).on("click", ".pagination_container .nav", function(e){
		e.preventDefault();
		console.log("clicked on nav")
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
				$.getJSON("/u/users/"+_options._userID, function(){
					console.log("... loading user#"+_options._userID+" profile info");
				})
				.done(function(data){
					//prepare leader info
					console.log(data);
					var _userDetail={};
					_userDetail["name"] = data.properties.first_name+" "+data.properties.last_name;
					_userDetail["profile_image"] = "/temp_dev_images/Tim.jpg";
					_userDetail["email"] = data.properties.email;
					_userDetail["phone"] = data.properties.phone;
					_userDetail["generation"] = _drillDownLevel;
					//for(key in data[0].rank[data[0].rank.length-1]) _userDetail["rank"] = key;

					_userDetail["downline_url"]=_getObjectsByCriteria(data, {rel:"user-children"})[0].href;


					//add new team drilldown basic template layout with leader info
					_html="<section class=\"drilldown level_"+_drillDownLevel+"\" data-drilldown-level=\""+_drillDownLevel+"\"></section>";
					$("#dashboard_team").append(_html);
					
					_drilldownContainerObj = $('#dashboard_team [data-drilldown-level='+_drillDownLevel+']');
					_drilldownContainerObj.css("opacity","0");
					// _drilldownContainerObj.scrollView(180);
					_drilldownContainerObj.animate({height:"+=250px", opacity:1}, _animation_speed);

					_getTemplate("/templates/drilldowns/_team_details.handlebars.html", 
						_userDetail, 
						_drilldownContainerObj,
						function(){
							//once the basic template is set, now populate the downlink information
							//had to do this as callback due to the asynchronous nature of the calls
							//animate up-arrow
							_drilldownContainerObj.find(".arrow").css("left",Math.floor(_options._arrowPosition-13));
							_drilldownContainerObj.find(".arrow").animate({top:"-=20px"}, 500);
							//populate downlink thumbnails
							_downlinkContainerObj = $('#dashboard_team [data-drilldown-level='+_drillDownLevel+'] .team_info .pagination_content');
							_ajax({
								_ajaxType:"get",
								_url:_userDetail.downline_url,
								_callback:function(data, text){

									_downlinkContainerObj.css("width", (_data.global.thumbnail_size.width*data.entities.length)+"px");
									if(data.entities.length>=4) _downlinkContainerObj.siblings(".nav").fadeIn();
									
									data.entities.forEach(function(member){
										_downlinkContainerObj.html("");
										_ajax({
											_ajaxType:"get",
											_url:"/u/users/"+member.properties.id+"/downline",
											_callback:function(data, text){
												_downlinkContainerObj
												member.properties.downline_count = data.entities.length;
												EyeCueLab.UX.getTemplate("/templates/_team_thumbnail.handlebars.html", member, undefined, function(html){
													_downlinkContainerObj.append(html);
												});
											}
										});
									});
								}
							});
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
				_drilldownContainerObj.animate({height:"+=608px", opacity:1}, _animation_speed);	

				//retrieve info from /customers/:id for the quote
				_userDetail={};
				_ajax({
					_ajaxType:"get", 
					_url:"/u/quotes/"+_options._userID, 
					_callback:function(data, text){
						var _updateAction={};
						var _userDetail = data.properties;
						$.extend(true, _updateAction, EyeCueLab.JSON.getObjectsByPattern(data, {"containsIn(fields)":{name:"zip"}})[0]);
						_updateAction.fields.forEach(function(field){
							_userDetail[field.name]=field.value;
						});
						//populate drilldown
						EyeCueLab.UX.getTemplate("/templates/drilldowns/_quotes_details.handlebars.html", _userDetail, _drilldownContainerObj, function(){
						 	_drilldownContainerObj.find(".arrow").css("left",Math.floor(_options._arrowPosition-13));
						 	_drilldownContainerObj.find(".arrow").animate({top:"-=20px"}, 500);
						 	$("#customer_contact_form select[name='state'] option").filter(function(){return $(this).text()==_userDetail.state}).attr("selected", true);
						 	$("#customer_contact_form select[name='roof_material'] option").filter(function(){return $(this).text()==_userDetail.roof_material}).attr("selected", true);

						 	$(".js-remove_quote").unbind();
						 	$("#customer_contact_form .js-update_customer_info").unbind();
						 	$(".js-resend_quote_email").unbind();
						 	$(".js-close_drilldown").unbind();

							$(".js-remove_quote").on("click", function(e){
								e.preventDefault();
								_thisThumbnail.find(".expand").click();
								_quoteID = $(e.target).parents(".drilldown_content").find("#customer_contact_form").attr("data-customer-id");
								_ajax({_ajaxType:"delete", _url:"/u/quotes/"+_quoteID, _callback:displayQuotes()});
							});

							$("#customer_contact_form .js-update_customer_info").on("click", function(e){
								e.preventDefault();
								_quoteID = $(e.target).parents(".drilldown_content").find("#customer_contact_form").attr("data-customer-id");
								_ajax({_ajaxType:"patch", _url:"/u/quotes/"+_quoteID, _postObj:$("#customer_contact_form").serializeObject(), _callback:displayQuotes()});
								_thisThumbnail.find(".expand").click();

							});

							$(".js-resend_quote_email").on("click", function(e){
								e.preventDefault();
								_quoteID = $(e.target).parents(".drilldown_content").find("#customer_contact_form").attr("data-customer-id");
								_ajax({_ajaxType:"post", _url:"/u/quotes/"+_quoteID+"/resend", _postObj:{}, _callback:displayQuotes()});
								_thisThumbnail.find(".expand").click();

							});		

							$(".js-close_drilldown").on("click" , function(){
								e.preventDefault();
								$(".js-new_quote_thumbnail .expand").click();
							});

						});
					}

				});

			break;

			case "new_quote":
				_drillDownLevel=$("#"+_options._mainSectionID+" .drilldown").length+1;
				_html="<section class=\"drilldown level_"+_drillDownLevel+"\" data-drilldown-level=\""+_drillDownLevel+"\"></section>";
				$("#"+_options._mainSectionID).append(_html);
				_drilldownContainerObj = $("#"+_options._mainSectionID+" [data-drilldown-level="+_drillDownLevel+"]");
				_drilldownContainerObj.css("opacity","0");
				_drilldownContainerObj.animate({height:"+=608px", opacity:1}, _animation_speed);	

				//populate drilldown
				EyeCueLab.UX.getTemplate("/templates/drilldowns/_new_quote.handlebars.html", {}, _drilldownContainerObj, function(){
				 	_drilldownContainerObj.find(".arrow").css("left",Math.floor(_options._arrowPosition-13));
				 	_drilldownContainerObj.find(".arrow").animate({top:"-=20px"}, 500);
					//wire up lead submission hook
					$("#new_lead_contact_form button").on("click", function(e){
						e.preventDefault();
						_formSubmit(e, $("#new_lead_contact_form"), "/u/quotes", "POST", function(data, text){
							//$(".js-new_quote_thumbnail .expand").click();
							$("#new_lead_contact_form").fadeOut(150, function(){
								$("#new_lead_contact_form input").val("");
								$("#new_lead_contact_form").fadeIn();
								displayQuotes();
							});
						});
					});

				});
			break;

			case "invitations":
				_drillDownLevel=$("#"+_options._mainSectionID+" .drilldown").length+1;
				_html="<section class=\"drilldown level_"+_drillDownLevel+"\" data-drilldown-level=\""+_drillDownLevel+"\"></section>";
				$("#"+_options._mainSectionID).append(_html);

				_drilldownContainerObj = $("#"+_options._mainSectionID+" [data-drilldown-level="+_drillDownLevel+"]");
				_drilldownContainerObj.css("opacity","0");
				_drilldownContainerObj.animate({height:"+=240px", opacity:1}, _animation_speed);	

				_data["invitations"]=[];
				//get listing array from json
				_getData(_myID, "invitations", _data["invitations"], function(){

					//pad the data object with blank invitations
					for(i=_data["invitations"].length; i<5; i++) _data["invitations"].push({});

					//first place the listing template
					_getTemplate("/templates/drilldowns/new_invitations/_invitations_listing.handlebars.html", {}, _drilldownContainerObj, function(){
						_drilldownContainerObj.find(".arrow").css("left",Math.floor(_options._arrowPosition-13));
				 		_drilldownContainerObj.find(".arrow").animate({top:"-=20px"}, 500);
	
				 		//display thumbnails
				 		_getTemplate("/templates/drilldowns/new_invitations/_invitations_thumbnail.handlebars.html",  _data["invitations"], _drilldownContainerObj.find(".drilldown_content_section"), function(){
			 				
			 				//wire up expiration timer
			 				_now = new Date();
			 				$(".js-expiration").each(function(){
			 					var _remainingSeconds, _remainingMinutes, _remainingHours;

			 					_expiration = new Date($(this).attr("data-expiration-timestamp"));
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
			 						if($(this).closest(".js-new_invite_thumbnail").attr("class").indexOf("js-empty_seat")<0)
			 							$(this).text("Expired");
			 					}
			 				});


							$(".js-new_invite_thumbnail").unbind();
							//wire up invitation detail hooks
							$(".js-new_invite_thumbnail").on("click", function(e){
								e.preventDefault();
								_drillDown({"_type":"new_invitations",
											"_mainSectionID":$(this).parents("section.dashboard_section").attr("id"), 
											"_thumbnailIdentifier":".js-new_invite_thumbnail",
											"_target":$(e.target),
											"_arrowPosition":$(this).find("span.expand i").offset().left});
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
				_drilldownContainerObj.animate({height:"+=400px", opacity:1}, _animation_speed);

				_invitationDetail = {};
				_invitationDetail = _data["invitations"][_thisThumbnail.index()];
				_invitationDetail.invitationType="Existing";
				_thisThumbnail = $(_options._target).parents(_options._thumbnailIdentifier);
				if(_thisThumbnail.attr("class").indexOf("js-empty_seat")>=0) _invitationDetail.invitationType="New";

				_getTemplate("/templates/drilldowns/new_invitations/_invitations_detail.handlebars.html", _invitationDetail, _drilldownContainerObj, function(){
					_drilldownContainerObj.find(".arrow").css("left",Math.floor(_options._arrowPosition-13));
				 	_drilldownContainerObj.find(".arrow").animate({top:"-=20px"}, 500);

					
					$("#new_promoter_invitation_form .button").unbind();
					$(".js-remove_advocate").unbind();
					$(".js-resend_invite_to_advocate").unbind();

					//wire up new invitation submission hook
					
					$("#new_promoter_invitation_form .button").on("click", function(e){
						e.preventDefault();
						_thisForm = $(e.target).closest("#new_promoter_invitation_form");
						_formSubmit(e, $("#new_promoter_invitation_form"), "/u/invites", "POST", _displayUpdatedInvitation)
					});

					//wire up remove pending advocate capabilities
					$(".js-remove_advocate").on("click", function(e){
						e.preventDefault();
						_id =$(e.target).closest(".drilldown_content_section").find(".invite_code").text();
						_ajax({_ajaxType:"delete", _url:"/u/invites/"+_id, _callback:_displayUpdatedInvitation()});
					});

					//wire up resend advocate invitation capaibiltiies 
					$(".js-resend_invite_to_advocate").on("click", function(e){
						e.preventDefault();
						_id =$(e.target).closest(".drilldown_content_section").find(".invite_code").text();
						_ajax({_ajaxType:"post", _url:"/u/invites/"+_id+"/resend", _callback:_displayUpdatedInvitation()});
					});	



				});

			break;


			case "impact_metrics":
				_drillDownLevel=$("#"+_options._mainSectionID+" .drilldown").length+1;
				_html="<section class=\"drilldown level_"+_drillDownLevel+"\" data-drilldown-level=\""+_drillDownLevel+"\"></section>";
				$("#"+_options._mainSectionID).append(_html);
				_drilldownContainerObj = $("#"+_options._mainSectionID+" [data-drilldown-level="+_drillDownLevel+"]");
				_drilldownContainerObj.css("opacity","0");
				_drilldownContainerObj.animate({height:"+=525px", opacity:1}, _animation_speed);	
				//_drilldownContainerObj.velocity({height:"+=490px", opacity:1}, _animation_speed);	
				var _templatePath;
				var _impactMetricsDetail = {};
				//todo: inject context/data under each template
				switch(_options._kpiType){
					case "environment":
						_templatePath="/templates/drilldowns/impact_metrics/_kpi_environment_details.handlebars.html";

					break;
					case "leads":
						_templatePath="/templates/drilldowns/impact_metrics/_kpi_quotes_details.handlebars.html";

					break;
					case "earnings":
						_templatePath="/templates/drilldowns/impact_metrics/_kpi_total_earnings_details.handlebars.html";
					break;
					case "team_members":
						_templatePath="/templates/drilldowns/impact_metrics/_kpi_genealogy_details.handlebars.html";
					break;
					case "type5":
						_templatePath="/templates/drilldowns/impact_metrics/_kpi_environment_details.handlebars.html";
					break;
				}

				_getTemplate(_templatePath, _data, _drilldownContainerObj, function(){
				 	_drilldownContainerObj.find(".arrow").css("left",Math.floor(_options._arrowPosition-13));
				 	_drilldownContainerObj.find(".arrow").animate({top:"-=20px"}, 500);
				 	if(_options._kpiType !== "environment") initKPI();
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
					_neighborThumbnail = $(_currentLevelSectionObj.find(_options._thumbnailIdentifier+":eq("+i+")"));
					_neighborThumbnail.animate({"opacity":".3"}, 300);
					_neighborThumbnail.find("span.expand i").removeClass("fa-angle-up");
					_neighborThumbnail.find("span.expand i").addClass("fa-angle-down");
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

			_thisThumbnail.animate({"opacity":1}, 300);
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

	function _collapseTeam(){
		$("#dashboard_team .js-team_thumbnail").animate({"opacity":1});
		$("#dashboard_team .js-team_thumbnail").removeClass("fa-angle-up");
		$("#dashboard_team .js-team_thumbnail").removeClass("fa-angle-down");
		$("#dashboard_team .js-team_thumbnail").addClass("fa-angle-down");

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
				_endPoint ="/u/users";
			break;
			
			case "quotes":
				_endPoint="/u/quotes";
			break;

			case "invitations":
				_endPoint="/u/invites";
			break;

			case "team":
				_endPoint ="/users";
			break;

			case "impact_metrics":
				return;
			break;

			default:
			break;


		}

		$.getJSON(_endPoint, function(){
			console.log("... loading user:"+_userID+" "+_dataType+" info");
		})
		.done(function(_d){
			if(typeof _dataStore !== "undefined"){
				if(Object.keys(_d).indexOf("entities")>=0){
					$.each(_d.entities, function(counter, val){ _dataStore.push(val.properties);});
				}else{
					//todo: fake data that needs to be replaced
					$.each(_d, function(counter, val){ _dataStore.push(val);});
				}
			}
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
				if (_dataObj.length==0) return;
				$.each(_dataObj, function(counter, val){
					_tempObj={};
					_tempObj["bindingObj"]=val.id+"_thumbnail";
					_tempObj["id"]=val.id;
					_tempObj["profile_image"]= (typeof val.profile_image === "undefined")? "/temp_dev_images/Tim.jpg" : val.profile_image;
					_tempObj["first_name"]= val.first_name;
					_tempObj["name"]= val.first_name+" "+val.last_name;
					_tempObj["phone"]= val.phone;
					_tempObj["email"]= val.email;
					_tempObj["rank"]="{no rank data}";
					/*for(key in val.rank[val.rank.length-1]) _tempObj["rank"] = key;
					_tempObj["quotes_approved"]= val.customers.quotes_approved.length;
					_tempObj["panels_installed"]= val.customers.panels_installed.length;
					_tempObj["team_size"]= val.genealogy.downlinks.length;*/
					_processedJSON.push(_tempObj);
				});
				_templatePath="/templates/_team_thumbnail.handlebars.html";
			break;

			case "quotes":
				if (_dataObj.length==0) return;
				$.each(_dataObj, function(counter, val){
					_tempObj={};
					_tempObj["bindingObj"]=val.id+"_thumbnail";
					_tempObj["id"]=val.id;
					_tempObj["first_name"]= val.first_name;
					_tempObj["last_name"]= val.last_name;
					_tempObj["name"]= val.full_name;
					_tempObj["status"]=val.status;

					for(i=0;i<val.data_status.length;i++)
						_tempObj[val.data_status[i]]="complete";

					_processedJSON.push(_tempObj);
				});
				_templatePath="/templates/_quote_thumbnail.handlebars.html";
			break;

		}
		//naive determine pagination 
		_containerObj.css("width", (_data.global.thumbnail_size.width*_processedJSON.length)+"px");

		//show pagination nav if thumbnail count is more than 4
		if(_processedJSON.length>=4) _containerObj.siblings(".nav").fadeIn();

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
					_remainingMinutes = 59;
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

	function _updateInvitationSummary(_callback){
		//update invitation summary
		_data["invitations"]=[];
		_getData(_myID, "invitations", _data["invitations"], function(){
			_availableInvitations = _data.global.total_invitations; 
			for(i=0;i<_data.invitations.length;i++) if(typeof _data.invitations[i].id !== "undefined") _availableInvitations--;
			$(".js-remaining_invitations").text(_availableInvitations);
			_expiredInvitations=0;
			for(i=0;i<_data.invitations.length;i++) {
			 	_now = new Date();
				_expiration = new Date(	_data.invitations[i].expires);
				_totalSeconds = Math.round((_expiration-_now)/1000);				
				if(_totalSeconds <0) _expiredInvitations++;
			}
			$(".js-expired_invitations").text(_expiredInvitations+" Expired");
			if(typeof _callback === "function") _callback();
		});
	}

	//responsible to close the drilldowns and reset invitation listing
	function _displayUpdatedInvitation(){
		$(".js-remaining_invitations").click();
		_updateInvitationSummary(function(){
			$(".js-remaining_invitations").click();
		});	
	}

	$(document).on("click", ".js-team_thumbnail", function(e){
		e.preventDefault();
		_drillDownUserID=$(e.target).parents(".js-team_thumbnail").attr("alt");
		_thisThumbnail = $(e.target).parents(".js-team_thumbnail");
		_drillDown({"_type":"team.everyone",
					"_mainSectionID":"dashboard_team", 
					"_thumbnailIdentifier":".js-team_thumbnail",
					"_target":$(e.target),
					"_userID":_drillDownUserID, 
					"_arrowPosition":_thisThumbnail.find("span.expand i").offset().left});
	});

}// end Dashboard class


// Faux form editing animations




$(document).on("focus", "input", function(e){
   var elem = $(this);

   // Save current value of element
   elem.data('oldVal', elem.val());

   // Look for changes in the value
   elem.bind("propertychange keyup input paste", function(event){
      // If value has changed...
      if (elem.data('oldVal') != elem.val()) {
       // Updated stored value
       elem.data('oldVal', elem.val());

		$(this).parents(".form_row").siblings(".form_edit_actions").fadeIn(100);

     }
   });
 });
