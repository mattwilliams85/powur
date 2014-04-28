
var _rank={};
var _data={}
var animation_speed = 300;
$(document).ready(function(){
	var _thisTeam = {};
	getTeamInfo(100, _thisTeam);
});


function getTeamInfo(_user_id, _thisTeam){
	$.getJSON("/assets/jsons/users."+_user_id+".team.json", function(){
		console.log("Loading loading self info");
	})
	.done(function(data){
		_thisTeam = jQuery.extend(true, {}, data);
		prepareTeamInfoTemplate(_thisTeam);
	});
}

function prepareTeamInfoTemplate(_thisTeam){
	var _team=[]
	$.each(_thisTeam, function(counter, val){
		console.log(counter);
		_tempObj={};
		_tempObj["id"]=val.info.id+"_thumbnail";
		_tempObj["profile_image"] = val.info.profile_image;
		_tempObj["name"]= val.info.first_name+" "+val.info.last_name;
		for(key in val.rank[val.rank.length-1]) _tempObj["rank"] = key;
		_tempObj["quotes_approved"]= val.customers.quotes_approved.length;
		_tempObj["panels_installed"]= val.customers.panels_installed.length;
		_tempObj["team_size"]= val.genealogy.downlinks.length;
		_team.push(_tempObj);
	});

	$("#test-section .section_content").loadTemplate("/assets/templates/team_thumbnail.html", _team);

	$(document).on("click",".team_thumbnail", function(e){
		_target = $(e.target);
		_drilldown=$(this).children(".object_detail");
		if(_drilldown.hasClass("active")) 
		{
			_drilldown.removeClass("active");
			_drilldown.fadeOut(animation_speed,"linear", function(){_drilldown.css("display","none");});
			$("#test-section").animate({"padding-bottom":"-=200px"},animation_speed);

		}else{
			//close other window in the same level
			_drilldown.addClass("active");
			_drilldown.fadeIn();
			$("#test-section").animate({"padding-bottom":"+=200px"},animation_speed);
		}
	});
}



