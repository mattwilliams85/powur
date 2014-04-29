
var _rank={};
var _data={}
var animation_speed = 300;
$(document).ready(function(){
	var _teamObj = {};
	getTeamInfo(100, _teamObj, "#test-section");
});


function getTeamInfo(_user_id, _teamObj, _bindingObj){
	$.getJSON("/assets/jsons/users."+_user_id+".team.json", function(){
		console.log("Loading loading self info");
	})
	.done(function(data){
		_teamObj = jQuery.extend(true, {}, data);
		prepareTeamInfoTemplate(_teamObj, _bindingObj);
	});
}

function prepareTeamInfoTemplate(_teamObj, _bindingObj){
	var _team=[]
	$.each(_teamObj, function(counter, val){
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

	$(_bindingObj+ " .section_content").loadTemplate("/assets/templates/team_thumbnail.html", _team);

	$(document).on("click",_bindingObj+" .team_thumbnail", function(e){
		_target = $(e.target);
		_drilldown=$(this).children(".object_detail");
		if(_drilldown.hasClass("active")) 
		{
			_drilldown.removeClass("active");
			_drilldown.fadeOut(animation_speed,"linear", function(){_drilldown.css("display","none");});
			$(_bindingObj).animate({"padding-bottom":"-=200px"},animation_speed);

		}else{
			//close other window in the same level
			_drilldown.addClass("active");
			_drilldown.fadeIn();
			$(_bindingObj).animate({"padding-bottom":"+=200px"},animation_speed);
		}
	});
}



