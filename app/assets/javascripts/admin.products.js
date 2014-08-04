//admin.js

var _data={};
var _dashboard;
_data.loadCategories=["currentUser", "products", "currentProduct", "ranks", "qualifications", "active_qualifications", "active_qualification_paths", "bonuses"];

jQuery(function($){

    $(document).on("click", ".admin_top_level_nav", function(e){
        window.location=($(e.target).attr("href").replace("#admin-","")=="plans")?"/a/products":"/a/users";
    });
    $(document).on("click", ".section_nav a", function(e){
        _dashboard.displayPlans($(e.target).attr("href"));
    });

    _data.loadTimer="";
    _data.load = function(){
        var _loading=false;
        for(i=0; i<_data.loadCategories.length;i++){
            if(typeof _data[_data.loadCategories[i]] === "undefined"){
                _loading=true;
                break;
            }
        }
        if(_loading) _data.loadTimer = setTimeout(_data.load, 10);
        else{
            clearTimeout(_data.loadTimer);
            for(i=0; i<_data.loadCategories.length;i++){
                console.log("complete: _data."+_data.loadCategories[i]);
            }
            _dashboard.displayPlans("#admin-plans-init");
        }
    }
    _data.load();

    _data.root={};
    _ajax({
        _ajaxType:"get",
        _url:"/",
        _callback:function(data, text){
            _data.root=data;
            _data.rootUsers=[];
            _data.currentUser={};
            _dashboard = new AdminDashboard();
            _dashboard.getRootUsers({_callback:function(){
                _data.currentUser=_data.rootUsers[0];
            }});
            _ajax({
                _ajaxType:"get",
                _url:"/a/products",
                _callback:function(data, text){
                    _data.products = data;
                    _data.currentProduct=data.entities[0];
                }
            });
            _ajax({
                _ajaxType:"get",
                _url:"/a/ranks",
                _callback:function(data, text){
                    _data.ranks = data;
                    _data.qualifications = {};

                    _getObjectsByCriteria(_data.ranks, "val=rank").forEach(function(_r){
                        _rank = _getObjectsByPath(_data.ranks, _r._path, -1);
                        _data.qualifications[_rank.properties.id]={};

                        _getObjectsByCriteria(_rank,  "val=qualification").forEach(function(_q){
                            //use path as a way to group qualifications
                            if(typeof _data.qualifications[_rank.properties.id][_getObjectsByPath(_rank, _q._path, -1).properties.path] === "undefined"){ 
                                _data.qualifications[_rank.properties.id][_getObjectsByPath(_rank, _q._path, -1).properties.path] =[];
                            }
                            _data.qualifications[_rank.properties.id][_getObjectsByPath(_rank, _q._path, -1).properties.path].push(_getObjectsByPath(_rank, _q._path, -1));
                        })
                    });
                }
            });
            
            _ajax({
                _ajaxType:"get",
                _url:"/a/qualifications",
                _callback:function(data, text){
                    _data.active_qualifications = data;
                    _data.active_qualification_paths ={};
                    _getObjectsByCriteria(_data.active_qualifications, "key=path").forEach(function(_p){
                        if(typeof _data.active_qualification_paths[_p.path] === "undefined") _data.active_qualification_paths[_p.path]=[];
                        _active_qualification = _getObjectsByPath(_data.active_qualifications, _p._path, -1);
                        _data.active_qualification_paths[_p.path].push(_active_qualification);

                    });
                }
            });


            _ajax({
                _ajaxType:"get",
                _url:"/a/bonuses",
                _callback:function(data, text){
                    _data.bonuses = data;
                    _data.bonuses.entities.forEach(function(_bonus){
                        //load bonus requirements
                        _ajax({
                            _ajaxType:"get",
                            _url:"/a/bonuses/"+_bonus.properties.id,
                            _callback:function(data, text){
                                //_bonus.bonus_levels = _getObjectsByPath(data, _getObjectsByCriteria(data, {0:"bonus_levels"})[0]._path, -1);
                                if(_getObjectsByCriteria(data.entities, "val=requirements").length>=1)
                                    _bonus.requirements = _getObjectsByPath(data.entities, _getObjectsByCriteria(data.entities, "val=requirements")[0]._path, -1);
                                if(_getObjectsByCriteria(data.entities, "val=bonus_levels").length>=1)
                                    _bonus.bonus_levels = _getObjectsByPath(data.entities, _getObjectsByCriteria(data.entities, "val=bonus_levels")[0]._path, -1);

                                _bonus.properties = data.properties;
                                _bonus.actions = data.actions;
                            }
                        });
                    });
                }
            });
        }
    });

    function AdminDashboard(){
        this.getRootUsers = getRootUsers;
        this.getGenealogy = getGenealogy;
        this.displayUsers = displayUsers;
        this.switchCurrentUser = switchCurrentUser;
        this.searchUser = searchUser;
        this.displayPlans = displayPlans;

        //function get root users if _id is undefined
        //otherwise get specific user info
        function getRootUsers(_options){
            if (typeof _options._id === "undefined"){
                _ajax({
                    _ajaxType:"get",
                    _url:"/a/users",
                    _callback:function(data, text){
                        data.entities.forEach(function(user, index){
                            _data.rootUsers.push(user.properties);
                            _data.rootUsers[index].actions = user.links;
                        });
                        if(typeof _options._callback === "function") _options._callback();
                    }
                });
                return _data.rootUsers;
            }
        }

        function displayPlans(_tab, _callback){
            switch(_tab){

                case "#admin-plans-init":
                    $(".js-dashboard_section_indicator.top_level").css("left", ($("#header_container nav a[href=#admin-plans]").position().left+28)+"px");
                    $(".js-dashboard_section_indicator.top_level").animate({"top":"-=15", "opacity":1}, 300);
                    displayPlans("#admin-plans-ranks");

                break;

                case "#admin-plans-ranks-init":
                    //refresh rank qualifications
                    _ajax({
                        _ajaxType:"get",
                        _url:"/a/ranks",
                        _callback:function(data, text){
                            _data.ranks = data;
                            _data.qualifications = {};

                            _getObjectsByCriteria(_data.ranks, "val=rank").forEach(function(_r){
                                _rank = _getObjectsByPath(_data.ranks, _r._path, -1);
                                _data.qualifications[_rank.properties.id]={};

                                _getObjectsByCriteria(_rank,  "val=qualification").forEach(function(_q){
                                    //use path as a way to group qualifications
                                    if(typeof _data.qualifications[_rank.properties.id][_getObjectsByPath(_rank, _q._path, -1).properties.path] === "undefined"){ 
                                        _data.qualifications[_rank.properties.id][_getObjectsByPath(_rank, _q._path, -1).properties.path] =[];
                                    }
                                    _data.qualifications[_rank.properties.id][_getObjectsByPath(_rank, _q._path, -1).properties.path].push(_getObjectsByPath(_rank, _q._path, -1));
                                    //_data.qualifications[_rank.properties.id].push(_getObjectsByPath(_rank, _q._path, -1));
                                });

                            });
                            //refresh active qualifications
                            _ajax({
                                _ajaxType:"get",
                                _url:"/a/qualifications",
                                _callback:function(data, text){
                                    _data.active_qualifications = data;
                                    _data.active_qualification_paths ={};
                                    _getObjectsByCriteria(_data.active_qualifications, "key=path").forEach(function(_p){
                                        if(typeof _data.active_qualification_paths[_p.path] === "undefined") _data.active_qualification_paths[_p.path]=[];
                                        _active_qualification = _getObjectsByPath(_data.active_qualifications, _p._path, -1);
                                        _data.active_qualification_paths[_p.path].push(_active_qualification);

                                    });
                                    displayPlans("#admin-plans-ranks");
                                }
                            });
                        }
                    });
                break;

                case "#admin-plans-ranks":
                    $(".js-admin_dashboard_detail_container, .js-admin_dashboard_column.summary").css("opacity",0);
                    //position indicator
                    _getTemplate("/templates/admin/plans/_nav.handlebars.html", {}, $(".js-admin_dashboard_column.detail .section_nav"), function(){
                        _positionIndicator($(".js-dashboard_section_indicator.second_level"), $(".js-admin_dashboard_column.detail nav.section_nav a[href=#admin-plans-ranks]"));
                    });

                    _summaryData={};
                    _getTemplate("/templates/admin/plans/ranks/_summary.handlebars.html", _summaryData, $(".js-admin_dashboard_column.summary"), function(){
                        //wire up add rank functionality
                        $(".js-add_new_rank").on("click", function(e){
                            e.preventDefault();
                            if(!_getObjectsByCriteria(_data.ranks.actions, "val=create").length) return;
                            var _popupData = [];
                            _popupData = _getObjectsByCriteria(_data.ranks.actions, "val=create")[0];
                            _popupData.fields.forEach(function(field){field.display_name=field.name.replace(/\_/g," ");});
                            _popupData.title="Add a new Rank";

                            $("#js-screen_mask").fadeIn(100, function(){
                                _getTemplate("/templates/admin/plans/popups/_standard_popup_container.handlebars.html",_popupData, $("#js-screen_mask"), function(){
                                    _displayPopup({_popupData:_popupData, _callback:function(){displayPlans("#admin-plans-ranks-init")}});
                                });
                            });
                        });
                    });

                    _getTemplate("/templates/admin/plans/ranks/_ranks.handlebars.html", _data.ranks, $(".js-admin_dashboard_detail_container"), function(){
                        $(".js-admin_dashboard_detail_container, .js-admin_dashboard_column.summary").animate({"opacity":1});
                        
                        //load active qualifications
                        for(_active_qualification_path in _data.active_qualification_paths){
                            _qualification_group=_data.active_qualification_paths[_active_qualification_path];
                            if(_qualification_group.length==0) return;
                            var _row =$("#js-active_qualification_row");
                            _row.find(".js-active_path").html("");
                            _padding=50*_qualification_group.length;

                            _row.find(".js-active_path").append("<div class='innerCell' style='height:"+_padding+"px'><span class='js-qualification_path label'>Path: "+_active_qualification_path+"</span>"+"<span style='line-height:20px;display:block; padding:5px 4px;'>Active Req.</span>");

                            _qualification_group.forEach(function(_qualification){
                                var _prod = (typeof _qualification.properties.product !== "undefined")? _qualification.properties.product : " ";
                                _row.find(".js-active_type").append("<div class='innerCell'><span class='label'>"+_prod+"</span>"+_qualification.properties.type_display.replace(/\_/g," ")+"</div><br style='clear:both;'>");
                                _conditions=[];
                                for(var _p in _qualification.properties){
                                    switch (_p){
                                        case "_path": case "path": case "type": case "id": case "type_display": case "product":
                                            //do not display these values
                                        break;
                                        default:
                                            _conditions.push( "<div class='innerCell'>"+("<span class='label'>"+_p+"</span>"+_qualification.properties[_p]).replace(/\_/g," ")+"</div>");
                                        break;
                                    }
                                }
                                _conditions.sort();
                                _conditions.reverse();

                                _row.find(".js-active_conditions").append(_conditions.join("")+"<br style='clear:both;'>");
                                _row.find(".js-active_actions").append("<div class='innerCell' style='vertical-align:middle;'><a href='#"+_qualification.properties.id+"' class='js-active_qualification_link' data-qualification-path='"+_active_qualification_path+"'>Edit Qualification</a></div><br style='clear:both;'>");
                            });
                        }
                        //wire up active qualification edit
                        $(".js-active_qualification_link").on("click", function(e){
                            e.preventDefault();
                            _qualificationID = parseInt($(e.target).attr("href").replace("#","")); 
                            _qualificationPath = $(e.target).attr("data-qualification-path");
                            _qualification=_data.active_qualification_paths[_qualificationPath].filter(function(_q){return _q.properties.id==_qualificationID})[0];
                            
                            var _popupData =[];
                            
                            _popupData = _qualification.actions.filter(function(action){return action.name==="update"})[0];
                            _popupData.fields.forEach(function(field){field.display_name=field.name.replace(/\_/g," ");});
                            _popupData.title="Editing Qaulification";
                            _popupData.deleteOption={};
                            _popupData.id=_qualificationID;
                            _popupData.deleteOption.name="Remove this Qualification";
                            _popupData.deleteOption.buttonName="js-delete_qualification";
                            _popupData.deleteOption.description="";
                            $("#js-screen_mask").fadeIn(100, function(){
                                _getTemplate("/templates/admin/plans/popups/_standard_popup_container.handlebars.html",_popupData, $("#js-screen_mask"), function(){
                                    _displayPopup({_popupData:_popupData, _callback:function(){displayPlans("#admin-plans-ranks-init")}});
                                });
                            });
                        });

                        //load rank qualifications
                        for(var _rankID in _data.qualifications){
                            if($.isEmptyObject(_data.qualifications[_rankID])) continue;

                            var _row =  $(".js-admin_dashboard_detail_container table tr[data-rank-id="+_rankID+"]");
                            var _rankObj = _data.ranks.entities.filter(function(rank){return rank.properties.id==_rankID})[0];
                            _row.find(".js-qualification_rank").html("");
                            for(_qualification_path in _data.qualifications[_rankID]){
                                _qualification_group=_data.qualifications[_rankID][_qualification_path];
                                _padding=50*_qualification_group.length;
                                _row.find(".js-qualification_rank").append("<div class='innerCell' style='height:"+_padding+"px'><span class='js-qualification_path label'>Path: "+_qualification_path+"</span><a href='#"+_rankID+"' class='js-rank_link'>"+_rankObj.properties.id+", "+_rankObj.properties.title+"</a>");

                                _qualification_group.forEach(function(_qualification){
                                    var _prod = (typeof _qualification.properties.product !== "undefined")? _qualification.properties.product : " ";
                                    _row.find(".js-qualification_type").append("<div class='innerCell'><span class='label'>"+_prod+"</span>"+_qualification.properties.type_display.replace(/\_/g," ")+"</div><br style='clear:both;'>");
                                    _conditions=[];
                                    for(var _p in _qualification.properties){
                                        switch (_p){
                                            case "_path": case "path": case "type": case "id": case "type_display": case "product":
                                                //do not display these values
                                            break;
                                            default:
                                                _conditions.push( "<div class='innerCell'>"+("<span class='label'>"+_p+"</span>"+_qualification.properties[_p]).replace(/\_/g," ")+"</div>");
                                            break;
                                        }
                                    }
                                    _conditions.sort();
                                    _conditions.reverse();

                                    _row.find(".js-qualification_conditions").append(_conditions.join("")+"<br style='clear:both;'>");
                                    _row.find(".js-qualification_actions").append("<div class='innerCell' style='vertical-align:middle;'><a href='#"+_qualification.properties.id+"' class='js-qualification_link' data-qualification-path='"+_qualification_path+"'>Edit Qualification</a></div><br style='clear:both;'>");
                                });
                            };
                        };

                        //wire up qualification edit
                        $(".js-qualification_link").on("click", function(e){
                            e.preventDefault();
                            _rankID = $(e.target).parents("tr").attr("data-rank-id");
                            _qualificationID = parseInt($(e.target).attr("href").replace("#","")); 
                            _qualificationPath = $(e.target).attr("data-qualification-path");
                            _qualification=_data.qualifications[_rankID][_qualificationPath].filter(function(_q){return _q.properties.id==_qualificationID})[0];
                            var _popupData =[];
                            _popupData = _qualification.actions.filter(function(action){return action.name==="update"})[0];
                            _popupData.fields.forEach(function(field){field.display_name=field.name.replace(/\_/g," ");});
                            _popupData.title="Editing Qaulification";
                            _popupData.deleteOption={};
                            _popupData.id=_qualificationID;
                            _popupData.deleteOption.name="Remove this Qualification";
                            _popupData.deleteOption.buttonName="js-delete_qualification";
                            _popupData.deleteOption.description="";
                            $("#js-screen_mask").fadeIn(100, function(){
                                _getTemplate("/templates/admin/plans/popups/_standard_popup_container.handlebars.html",_popupData, $("#js-screen_mask"), function(){
                                    _displayPopup({_popupData:_popupData, _callback:function(){displayPlans("#admin-plans-ranks-init")}});
                                });
                            });
                        });

                        //wire up rank edit
                        $(".js-rank_link").on("click", function(e){
                            e.preventDefault();
                            _rankID = parseInt($(e.target).attr("href").replace("#",""));                 
                            _ajax({
                                _ajaxType:"get",
                                _url:"/a/ranks/"+_rankID,
                                _callback:function(data, text){
                                    var _popupData = [];
                                    _popupData = data.actions[0];
                                    _popupData.fields.forEach(function(field){field.display_name=field.name.replace(/\_/g," ");});
                                    _popupData.title="Editing Rank "+data.properties.id+", "+data.properties.title;
                                    _popupData.deleteOption={};
                                    _popupData.id=_rankID;
                                    _popupData.deleteOption.name="Remove "+data.properties.id+", "+data.properties.title;

                                    if(_data.ranks.entities.length == _rankID) _popupData.deleteOption.buttonName="js-delete_rank";
                                    _popupData.deleteOption.description="Only the highest Rank can be removed at this time";
                                    $("#js-screen_mask").fadeIn(100, function(){
                                        _getTemplate("/templates/admin/plans/popups/_standard_popup_container.handlebars.html",_popupData, $("#js-screen_mask"), function(){
                                            _displayPopup({_popupData:_popupData, _callback:function(){displayPlans("#admin-plans-ranks-init")}});
                                        });
                                    });
                                }
                            });
                        });

                        //wire up add rank qualifications
                        $(".js-add_qualification").on("click", function(e){
                            e.preventDefault();
                            _rankID = parseInt($(e.target).parents("tr").attr("data-rank-id"));
                            _ajax({
                                _ajaxType:"get",
                                _url:"/a/ranks/"+_rankID,
                                _callback:function(data, text){
                                    var _popupData = [];
                                    _popupData =_getObjectsByCriteria(data, "val~qualification").filter(function(action){return action.name=="create"})[0];
                                    _popupData.id=_rankID;
                                    _popupData.popupType = "hierarchical";
                                    _popupData.primaryOptions=[];
                                    
                                    _popupData.fields.forEach(function(field){
                                        field.display_name=field.name.replace(/\_/g," ");
                                        if (typeof field.visibility === "undefined"){
                                            _popupData.primaryOptions.push(_getObjectsByCriteria(_popupData.fields,{name:field.name})[0]); 
                                        }
                                    });

                                    _popupData.title="Add a New Qualification<br>for Rank "+data.properties.id+", "+data.properties.title;
                                    _populateReferencialSelect({_popupData:_popupData});

                                    $("#js-screen_mask").fadeIn(100, function(){
                                        _getTemplate("/templates/admin/plans/popups/_hierarchical_popup_container.handlebars.html",_popupData, $("#js-screen_mask"), function(){
                                            _displayPopup({_popupData:_popupData, _callback:function(){displayPlans("#admin-plans-ranks-init")}});
                                        });
                                    });
                                }
                            });
                        });

                        //wire up add active qualifications
                        $(".js-add_active_qualification").on("click", function(e){
                            e.preventDefault();
                            var _popupData=[];
                            _popupData =_getObjectsByCriteria(_data.active_qualifications, "val~qualification").filter(function(action){return action.name=="create"})[0];
                            _popupData.popupType = "hierarchical";
                            _popupData.primaryOptions=[];

                            _popupData.fields.forEach(function(field){
                                field.display_name=field.name.replace(/\_/g," ");
                                if (typeof field.visibility === "undefined"){
                                    _popupData.primaryOptions.push(_getObjectsByCriteria(_popupData.fields,{name:field.name})[0]); 
                                }
                            });

                            _popupData.title="Add a New Qualification<br>for an Active User";
                            _populateReferencialSelect({_popupData:_popupData});

                            $("#js-screen_mask").fadeIn(100, function(){
                                _getTemplate("/templates/admin/plans/popups/_hierarchical_popup_container.handlebars.html",_popupData, $("#js-screen_mask"), function(){
                                    _displayPopup({_popupData:_popupData, _callback:function(){displayPlans("#admin-plans-ranks-init")}});
                                });
                            });

                        });

                    });

                break;

                case "#admin-plans-products-init":
                    _ajax({
                        _ajaxType:"get",
                        _url:"/a/products",
                        _callback:function(data, text){
                            _data.products = data;
                            _data.currentProduct=data.entities[0];
                            displayPlans("#admin-plans-products");
                        }
                    });
                break;

                case "#admin-plans-products":
                    $(".js-admin_dashboard_detail_container, .js-admin_dashboard_column.summary").css("opacity",0);

                    //position indicator
                    _getTemplate("/templates/admin/plans/_nav.handlebars.html", {}, $(".js-admin_dashboard_column.detail .section_nav"), function(){
                        _positionIndicator($(".js-dashboard_section_indicator.second_level"), $(".js-admin_dashboard_column.detail nav.section_nav a[href=#admin-plans-products]"));
                    });
                    _summaryData={};
                    _summaryData.entities=_data.products.entities;
                    _summaryData.currentProduct=_data.currentProduct;
                    _getTemplate("/templates/admin/plans/products/_summary.handlebars.html", _summaryData, $(".js-admin_dashboard_column.summary"), function(){
                        //wire up edit product button
                        $( ".js-edit_product").on("click", function(e){
                            e.preventDefault();
                            var _popupData = [];
                            _ajax({
                                _ajaxType:"get",
                                _url:"/a/products/"+_data.currentProduct.properties.id,
                                _callback:function(data, text){
                                    _popupData = _getObjectsByCriteria(data, "val=update")[0];
                                    _popupData.fields.forEach(function(field){field.display_name=field.name.replace(/\_/g," ");});
                                    _popupData.title="Editing "+data.properties.name;
                                    _popupData.deleteOption={};
                                    _popupData.id=_data.currentProduct.properties.id;
                                    _popupData.deleteOption.name="Remove "+data.properties.name;
                                    _popupData.deleteOption.buttonName="js-delete_product";
                                    _popupData.deleteOption.description="When you remove a product, all compensation calculation will be removed immediately.  Please exercise with caution."

                                    $("#js-screen_mask").fadeIn(100, function(){
                                        _getTemplate("/templates/admin/plans/popups/_standard_popup_container.handlebars.html",_popupData, $("#js-screen_mask"), function(){
                                            _displayPopup({_popupData:_popupData, _callback:function(){displayPlans("#admin-plans-products-init")}});
                                        });
                                    });
                                }
                            });
                        });

                        //wire up new product button
                        $(".js-add_new_product").on("click", function(e){
                            e.preventDefault();
                            if(!_getObjectsByCriteria(_data.products, "val=create").length) return;
                            var _popupData = [];
                            _popupData = _getObjectsByCriteria(_data.products, "val=create")[0];
                            _popupData.fields.forEach(function(field){field.display_name=field.name.replace(/\_/g," ");});
                            _popupData.title="Add a new product";

                            $("#js-screen_mask").fadeIn(100, function(){
                                _getTemplate("/templates/admin/plans/popups/_standard_popup_container.handlebars.html",_popupData, $("#js-screen_mask"), function(){
                                    _displayPopup({_popupData:_popupData, _callback:function(){displayPlans("#admin-plans-products-init")}});
                                });
                            });
                        });

                        //wire up product switching control
                        $(".js-product_select").on("change", function(e){
                            switchCurrentProduct(e);
                        });
                    });

                    _getTemplate("/templates/admin/plans/products/_products.handlebars.html", _data.currentProduct, $(".js-admin_dashboard_detail_container"), function(){
                        $(".js-admin_dashboard_detail_container, .js-admin_dashboard_column.summary").animate({"opacity":1});
                        $(".js-product_select option[value="+_data.currentProduct.properties.id+"]").attr("selected", "selected");
                        
                    });
                break;

                case "#admin-plans-bonuses-init":
                    _ajax({
                        _ajaxType:"get",
                        _url:"/a/bonuses",
                        _callback:function(data, text){
                            _data.bonuses = data;
                            _data.bonuses.entities.forEach(function(_bonus){
                                //load bonus requirements
                                _ajax({
                                    _ajaxType:"get",
                                    _url:"/a/bonuses/"+_bonus.properties.id,
                                    _callback:function(data, text){
                                        //_bonus.bonus_levels = _getObjectsByPath(data, _getObjectsByCriteria(data, {0:"bonus_levels"})[0]._path, -1);
                                        if(_getObjectsByCriteria(data.entities, "val=requirements").length>=1)
                                            _bonus.requirements = _getObjectsByPath(data.entities, _getObjectsByCriteria(data.entities, "val=requirements")[0]._path, -1);
                                        if(_getObjectsByCriteria(data.entities, "val=bonus_levels").length>=1)
                                            _bonus.bonus_levels = _getObjectsByPath(data.entities, _getObjectsByCriteria(data.entities, "val=bonus_levels")[0]._path, -1);

                                        _bonus.properties = data.properties;
                                        _bonus.actions = data.actions;
                                        displayPlans("#admin-plans-bonuses");

                                    }
                                });
                            });
                        }
                    });

                break;

                case "#admin-plans-bonuses":
                    $(".js-admin_dashboard_detail_container, .js-admin_dashboard_column.summary").css("opacity",0);
                    //position indicator
                    _getTemplate("/templates/admin/plans/_nav.handlebars.html", {}, $(".js-admin_dashboard_column.detail .section_nav"), function(){
                        _positionIndicator($(".js-dashboard_section_indicator.second_level"), $(".js-admin_dashboard_column.detail nav.section_nav a[href=#admin-plans-bonuses]"));
                    });

                    _summaryData={};
                    _summaryData.entities=_data.bonuses.entities;
                    _getTemplate("/templates/admin/plans/bonuses/_summary.handlebars.html", _summaryData, $(".js-admin_dashboard_column.summary"), function(){
                        //wire up the ability to add a new bonus
                        $(".js-add_new_bonus").on("click", function(e){
                            e.preventDefault();
                            var _popupData = [];
                            _popupData = _getObjectsByCriteria(_data.bonuses.actions, {name:"create"})[0];
                            _popupData.fields.forEach(function(field){
                                field.display_name=field.name.replace(/\_/g," ");
                                if(typeof field.options !=="undefined") delete field.options["_path"];
                            });
                            _popupData.title="Create a new Bonus";
                            _populateReferencialSelect({_popupData:_popupData});

                            $("#js-screen_mask").fadeIn(100, function(){
                                _getTemplate("/templates/admin/plans/popups/_standard_popup_container.handlebars.html",_popupData, $("#js-screen_mask"), function(){
                                    _displayPopup({_popupData:_popupData, _callback:function(){displayPlans("#admin-plans-bonuses-init")}});
                                });
                            }); 
                        });
                    });

                    _getTemplate("/templates/admin/plans/bonuses/_bonuses.handlebars.html", _data.bonuses , $(".js-admin_dashboard_detail_container"), function(){
                        $(".js-admin_dashboard_detail_container, .js-admin_dashboard_column.summary").animate({"opacity":1});
                        
                        _data.bonuses.entities.forEach(function(_bonus){
                            delete _bonus.properties["_path"];
                            var _bonusID = _bonus.properties.id;
                            var _row =  $(".js-admin_dashboard_detail_container table tr[data-bonus-id="+_bonusID+"]");
                            var _descriptions =[];
                            var _display="";

                            //show bonus details
                            _row.find(".js-bonus_details").html("");
                            _display="<h4 class='subRow'>// Summary</h4>";

                            Object.keys(_bonus.properties).forEach(function(_key){
                                var _skip=false;
                                if((!_bonus.properties[_key]) || (_bonus.properties[_key].toString().length==0))_bonus.properties[_key]="<span class='js-no_data'>No Data</span>";
                                ["id", "name", "amounts"].forEach(function(_skipKey){if (_key===_skipKey) _skip=true;});
                                if(!_skip) _display+="<div class='innerCell'><span class='label'>"+_key.replace(/\_/g," ").replace(/percentage/i, "%")+"</span><span class='content'>"+_bonus.properties[_key]+"</span></div>";
                            });
                            _row.find(".js-bonus_details").append(_display);
                            _row.find(".js-bonus_details").append("<br style='clear:both;'>");
                            

                            //show requirements
                            if(typeof _bonus.requirements !== "undefined" && _bonus.requirements.entities.length>0){
                                _display="<h4 class='subRow'>// Requirements</h4>";
                                _bonus.requirements.entities.forEach(function(_requirement){
                                    var _properties=_requirement.properties;
                                    delete _properties._path;
                                    delete _properties.product_id;
                                    JSON.stringify(_properties).replace(/\_/g, " ").replace(/["{}]/g, "").split(",").forEach(function(_property){
                                        _display+="<div class='innerCell'><span class='label'>"+_property.split(":")[0]+"</span><span class='content'>"+_property.split(":")[1]+"</span></div>";
                                    });
                                    _display +="<div class='innerCell' style='display:block; float:right;'><a class='js-edit_bonus_requirement' href='#"+_getObjectsByCriteria(_requirement, {name: "update"})[0].href+"'>Edit Requirement</a></div><br style='clear:both;'>";
                                });
                                _row.find(".js-bonus_details").append(_display);
                            }

                            //show bonus payments
                            var _amountDetail = _getObjectsByCriteria(_bonus.actions, {name: "amounts"})[0];
                            if((typeof _bonus.properties.amounts !== "undefined" && _bonus.properties.amounts.length>0 ) || (typeof _bonus.bonus_levels !== "undefined")){
                                _display="<h4 class='subRow'>// Bonus Payments</h4>";
                                if((typeof _amountDetail === "undefined") && (typeof _bonus.bonus_levels === "undefined")) _display+="Please select a product source";
                                else{
                                    if(typeof _bonus.bonus_levels !=="undefined"){
                                        //show uni-level payment structure
                                        if(_bonus.bonus_levels.entities.length==0) _display+="Please add a bonus level";
                                        _bonus.bonus_levels.entities.forEach(function(_bonus_level, _index){
                                            var _amountDetail = _getObjectsByCriteria(_bonus_level, "key=total")[0];
                                            var _amount = _bonus_level.properties.amounts;

                                            _display+="<div class='rotate js-bonus_level_label'>Level "+(_index+1)+"</div><div class='js-bonus_level_bracket'></div>";
                                            _display+="<div class='js-bonus_level_amount_container'>";
                                            _data.ranks.entities.forEach(function(_rank, _index){
                                                _display+="<div class='innerCell'><span class='label'>"+_rank.properties.id+", "+_rank.properties.title+"</span><span class='content'>"+(_amount[_index]*100).toFixed(0)+"% <span style='font-size:11px; color:#9b9b9b;'>$"+(_amount[_index]*_amountDetail.total).toFixed(0)+"</span></span></div>";
                                            });
                                            _display+="</div>";
                                            _display+="<div class='innerCell' style='display:block; float:right;'><a class='js-edit_bonus_level_payment' href='#"+_getObjectsByCriteria(_bonus_level.actions, {name: "update"})[0].href+"'>Adjust Payments</a></div>";
                                            _display+="<br style='clear:both;'>"
                                            _row.find(".js-bonus_details").append(_display);
                                            _display="";
                                            _row.find(".js-bonus_level_bracket:eq("+_index+")").css("height",  (_row.find(".js-bonus_level_amount_container:eq("+_index+")").height()-5)+"px");
                                        });

                                    }else{
                                        //show all other payment structure
                                        delete _bonus.properties.amounts._path;
                                        _bonus.properties.amounts.forEach(function(_amount, _index){
                                            var _rankID = _amountDetail.first+_index;
                                            if (_rankID <= _amountDetail.last){
                                                var _rankTitle = _getObjectsByCriteria(_data.ranks.entities, {id:_rankID}).filter(function(_rank){return typeof _rank.title!=="undefined"})[0].title;
                                                _display+="<div class='innerCell'><span class='label'>"+_rankID+", "+_rankTitle+"</span><span class='super'>"+(_amount*100).toFixed(0)+"% <span class='sub'>$"+(_amount*_amountDetail.total).toFixed(0)+"</span></span></div>";

                                            }
                                        });
                                            _display+="<div class='innerCell' style='display:block; float:right;'><a class='js-edit_bonus_payment' href='#'>Adjust Payments</a></div>";
                                        _row.find(".js-bonus_details").append(_display);
                                    }
                                }
                            }
                        });
                        
                        //wire up the edit bonus link
                        $(".js-bonus_link").on("click", function(e){
                            e.preventDefault();
                            var _popupData = [];
                            var _bonusID= $(e.target)[0].tagName.toLowerCase()==="select"? parseInt($(e.target).val().replace("#","")) : parseInt($(e.target).attr("href").replace("#",""));
                            _bonus = _getObjectsByPath(_data.bonuses, _getObjectsByCriteria(_data.bonuses, {id:_bonusID})[0]._path, -1);
                            _popupData = _getObjectsByCriteria(_bonus.actions, "val=update")[0];

                            //hide the amounts form the update
                            //eval("delete _popupData"+(_getObjectsByCriteria(_popupData, {name:"amounts"})[0]._path.replace(/\//g,"\"][\"")+"\"]").substring(2));

                            _popupData.fields.forEach(function(field){field.display_name=field.name.replace(/\_/g," ");});
                            _popupData.title="Editing "+_bonus.properties.name;
                            _popupData.deleteOption={};
                            _popupData.id=_bonusID;
                            _popupData.deleteOption.name="Remove "+_bonus.properties.name;
                            _popupData.deleteOption.buttonName="js-delete_bonus";
                            _popupData.deleteOption.description="When you remove a bonus, all compensation calculation will be removed immediately.  Please exercise with caution."

                            _populateReferencialSelect({_popupData:_popupData});

                            $("#js-screen_mask").fadeIn(100, function(){
                                _getTemplate("/templates/admin/plans/popups/_standard_popup_container.handlebars.html",_popupData, $("#js-screen_mask"), function(){
                                    _displayPopup({_popupData:_popupData, _callback:function(){displayPlans("#admin-plans-bonuses-init")}});
                                });
                            });
                        });

                        //wire up add bonus requirement link
                        $(".js-add_bonus_requirement").on("click", function(e){
                            e.preventDefault();
                            var _popupData=[];
                            var _bonusID = $(e.target).parents("tr").attr("data-bonus-id");
                            var _bonus = _getObjectsByPath(_data.bonuses, _getObjectsByCriteria(_data.bonuses, {id:_bonusID})[0]._path, -1);
                            
                            _popupData = _getObjectsByCriteria(_bonus.requirements, {name:"create"})[0];
                            _popupData.fields.forEach(function(field){
                                field.display_name=field.name.replace(/\_/g," ");
                                if(typeof field.options !=="undefined") delete field.options["_path"];
                            });
                            _popupData.title="Create a new Bonus";

                            _populateReferencialSelect({_popupData:_popupData});

                            $("#js-screen_mask").fadeIn(100, function(){
                                _getTemplate("/templates/admin/plans/popups/_standard_popup_container.handlebars.html",_popupData, $("#js-screen_mask"), function(){
                                    _displayPopup({_popupData:_popupData, _callback:function(){displayPlans("#admin-plans-bonuses-init")}});
                                });
                            }); 
                        });

                        //wire up edit bonus requirement link
                        $(".js-edit_bonus_requirement").on("click", function(e){
                            e.preventDefault();
                            var _popupData=[];
                            var _requirementHref = $(e.target).attr("href").replace("#","");
                            var _popupData = _getObjectsByCriteria(_data.bonuses, "val="+_requirementHref).filter(function(_action){return _action.name=="update"})[0];
                            var _bonus = _getObjectsByPath(_data.bonuses, _popupData._path ,-5);

                            _popupData.fields.forEach(function(field){field.display_name=field.name.replace(/\_/g," ");});
                            _popupData.title="Editing Bonus Requirement<br> For Bonus: "+_bonus.properties.name;
                            _popupData.deleteOption={};
                            _popupData.href=_requirementHref;
                            //_popupData.id=_bonusID;
                            _popupData.deleteOption.name="Remove this Requirement";
                            _popupData.deleteOption.buttonName="js-delete_bonus_requirement";
                            _popupData.deleteOption.description="When you remove a bonus requirement, all compensation calculation will be changed immediately.  Please exercise with caution."

                            _populateReferencialSelect({_popupData:_popupData});

                            $("#js-screen_mask").fadeIn(100, function(){
                                _getTemplate("/templates/admin/plans/popups/_standard_popup_container.handlebars.html",_popupData, $("#js-screen_mask"), function(){
                                    _displayPopup({_popupData:_popupData, _callback:function(){displayPlans("#admin-plans-bonuses-init")}});
                                });
                            });
                        });

                        //wire up edit bonus payment link
                        $(".js-edit_bonus_payment").on("click", function(e){
                            e.preventDefault();
                            var _popupData=[];
                            var _bonusID = $(e.target).parents("tr").attr("data-bonus-id");
                            var _bonus = _getObjectsByPath(_data.bonuses, _getObjectsByCriteria(_data.bonuses, {id:_bonusID})[0]._path, -1);

                            _popupData = _getObjectsByCriteria(_bonus.actions, {name: "update"})[0];
                            _popupData.popupType = "bonus_payment";                            
                            _popupData._bonusID = _bonusID;
                            _popupData["properties"] = {};
                            $.extend(true, _popupData.properties, _bonus.properties);
                            _popupData.amountDetail = _getObjectsByCriteria(_popupData, {name:"amounts"})[0];
                            _popupData.amountDetail.maxPercentage = (_popupData.amountDetail.max*100.00).toFixed(0);
                            _popupData.title="Editing Payments<br> For Bonus: "+_bonus.properties.name;
                            //_populateReferencialSelect({_popupData:_popupData});

                            $("#js-screen_mask").fadeIn(100, function(){
                                _getTemplate("/templates/admin/plans/popups/_bonus_payment_container.handlebars.html",_popupData, $("#js-screen_mask"), function(){
                                    _displayPopup({_popupData:_popupData, _callback:function(){displayPlans("#admin-plans-bonuses-init")}});
                                });
                            });
                        });

                        //wire up add new bonus level
                        $(".js-add_bonus_level").on("click", function(e){
                            e.preventDefault();
                            var _popupData=[];
                            var _bonusID = $(e.target).parents("tr").attr("data-bonus-id");
                            var _bonus = _getObjectsByPath(_data.bonuses, _getObjectsByCriteria(_data.bonuses, {id:_bonusID})[0]._path, -1);
                            
                            _popupData = _getObjectsByCriteria(_bonus.bonus_levels.actions, {name: "create"})[0];
                            _popupData.popupType = "bonus_payment";                            
                            _popupData._bonusID = _bonusID;
                            _popupData["properties"] = {};
                            $.extend(true, _popupData.properties, _bonus.properties);
                            //prep artificial amounts
                            _popupData.properties["amounts"]=[];
                            for(i=0;i<_data.ranks.entities.length;i++) _popupData.properties["amounts"].push(0.00);
                            _popupData.amountDetail = {};
                            $.extend(true, _popupData.amountDetail, _getObjectsByCriteria(_popupData, {name: "amounts"})[0]);
                            _popupData.amountDetail.maxPercentage = (_popupData.amountDetail.max*100.00).toFixed(0);

                            _popupData.title="Add a new Bonus Level <br> For Bonus: "+_bonus.properties.name;

                            $("#js-screen_mask").fadeIn(100, function(){
                                _getTemplate("/templates/admin/plans/popups/_bonus_payment_container.handlebars.html",_popupData, $("#js-screen_mask"), function(){
                                    _displayPopup({_popupData:_popupData, _callback:function(){displayPlans("#admin-plans-bonuses-init")}});
                                });
                            });
                        });
                        
                        //wire up edit bonus level payments
                        $(".js-edit_bonus_level_payment").on("click", function(e){
                            e.preventDefault();
                            var _popupData=[];
                            var _bonusID = $(e.target).parents("tr").attr("data-bonus-id");
                            var _bonus = _getObjectsByPath(_data.bonuses, _getObjectsByCriteria(_data.bonuses, {id:_bonusID})[0]._path, -1);
                            var _bonuseLevelPaymentHref = $(e.target).attr("href").replace("#","");
                            var _bonus_levels=_getObjectsByPath(_data.bonuses, _bonus._path).bonus_levels;
                            var _last_bonus_level =false;

                            _popupData=_getObjectsByCriteria(_data.bonuses, {href:_bonuseLevelPaymentHref}).filter(function(_action){return _action.name=="update"})[0];
                            if(_getObjectsByCriteria(_data.bonuses, {href:_bonuseLevelPaymentHref}).filter(function(_action){return _action.name=="delete"}).length>0) _last_bonus_level= true;
                            _popupData.popupType = "bonus_payment";                            
                            _popupData._bonusID = _bonusID;
                            
                            _popupData["properties"] = {};
                            $.extend(true, _popupData.properties, _bonus.properties);
                            
                            _popupData.properties["amounts"]=[];
                            delete _getObjectsByPath(_bonus_levels, _getObjectsByCriteria(_bonus_levels, {href:_bonuseLevelPaymentHref})[0]._path, -2).properties.amounts._path;
                            $.extend(true, _popupData.properties.amounts, _popupData.properties.amounts=_getObjectsByPath(_bonus_levels, _getObjectsByCriteria(_bonus_levels, {href:_bonuseLevelPaymentHref})[0]._path, -2).properties.amounts);
                            
                            _popupData.amountDetail = {};
                            $.extend(true, _popupData.amountDetail, _getObjectsByCriteria(_popupData, {name: "amounts"})[0]);
                            _popupData.amountDetail.maxPercentage = (_popupData.amountDetail.max*100.00).toFixed(0);

                            _popupData.title="Edit a Bonus Level <br> For Bonus: "+_bonus.properties.name;
                            
                            if(_last_bonus_level){
                                _popupData.deleteOption={};
                                _popupData.href=_bonuseLevelPaymentHref;
                                _popupData.deleteOption.name="Remove this Bonus Level";
                                _popupData.deleteOption.buttonName="js-delete_bonus_level";
                                _popupData.deleteOption.description="When you remove a bonus level, all compensation calculation will be changed immediately.  Please exercise with caution."
                            }
                            
                            $("#js-screen_mask").fadeIn(100, function(){
                                _getTemplate("/templates/admin/plans/popups/_bonus_payment_container.handlebars.html",_popupData, $("#js-screen_mask"), function(){
                                    _displayPopup({_popupData:_popupData, _callback:function(){displayPlans("#admin-plans-bonuses-init")}});
                                });
                            });

                            //console.log(_popupData)
                        });

                    });
                break;
            }
        }


        function displayUsers(_tab, _callback){

            switch(_tab){
                case "#admin-users-init":
                case "#admin-users-membership":
                case "#admin-users-membership-basic_info":
                    _ajax({
                        _ajaxType:"get",
                        _url:"/a/users/"+_data.currentUser.id,
                        _callback:function(data, text){
                            _data.currentUser= _getObjectsByCriteria(data, "key=address")[0];
                            _data.currentUser.actions = _getObjectsByCriteria(data, "key=rel");

                            if(_tab==="#admin-users-init"){ 
                                //set up indicator for top level  
                                $(".js-dashboard_section_indicator.top_level").css("left", ($("#header_container nav a[href=#admin-users]").position().left+28)+"px");
                                $(".js-dashboard_section_indicator.top_level").animate({"top":"-=15", "opacity":1}, 300);

                                //wire up navigation 
                                $(document).on("click", "nav.section_nav a, nav.section_subnav a", function(e){
                                    e.preventDefault();
                                    _dashboard.displayUsers($(this).attr("href"));
                                });
                                //wire up additional logic to allow switching of current user (that you are looking at)
                                $(document).on("click", ".js-user_link", function(e){_dashboard.switchCurrentUser(e)});
                                $(document).on("change", ".js-user_select", function(e){_dashboard.switchCurrentUser(e)});

                                //wire up search
                                $(document).on("keypress", ".js-search_box", function(e){
                                    if(e.keyCode == 13){
                                        _dashboard.searchUser($(e.target).val());
                                    }
                                });

                                //prepare the drop down for the root user on the left nav
                                _data.currentUser["userDropDown"]=[];
                                _data.rootUsers.forEach(function(rootUser){
                                    if(typeof rootUser !== "undefined"){
                                          _data.currentUser["userDropDown"].push({
                                            first_name:rootUser.first_name, 
                                            last_name:rootUser.last_name,
                                            id:rootUser.id
                                        });
                                    }
                                });
                            }

                            //retrieve genealogy info for current user
                            getGenealogy({
                                _callback:function(){
                                    _data.currentUser.immediateUpline=_data.currentUser.upline[Object.keys(_data.currentUser.upline).length-1];
                                    _getTemplate("/templates/admin/users/membership/_summary.handlebars.html", _data.currentUser, $(".js-admin_dashboard_column.summary"));

                                    //display main content information of the current user on the left nav
                                    _getTemplate("/templates/admin/users/_detail_container.handlebars.html", _data.currentUser, $(".js-admin_dashboard_detail_container"), function(){

                                        _positionIndicator($(".js-dashboard_section_indicator.second_level"), $(".js-admin_dashboard_column.detail nav.section_nav a[href=#admin-users-membership]"));

                                        //load editable form for the current user on the main pane 
                                        $(".js-admin_dashboard_detail").fadeOut(100, function(){
                                            _getTemplate("/templates/admin/users/membership/_basic_info.handlebars.html", _data.currentUser,  $(".js-admin_dashboard_detail"));
                                            $(".js-admin_dashboard_detail").fadeIn(300);
                                        });
                                    });
                                }
                            });
                        }
                    });

                    //wire up the udpate button for the current user
                    $(document).on("click", ".js-update_distributor_info", function(e){
                        e.preventDefault();
                        _ajax({
                            _ajaxType:"patch",
                            _url:"/a/users/"+_data.currentUser.id,
                            _postObj:$("#admin-users-membership-basic_info-contact_form").serializeObject(),
                            _callback:function(data, text){
                                _dashboard.displayUsers("#admin-users-membership-basic_info");
                            }
                        })
                    });

                    //%TODO: wire up  force rank override button
                    //

                break;


               case "#admin-users-genealogy":
                        _getTemplate("/templates/admin/users/genealogy/_summary.handlebars.html", _data.currentUser,  $(".js-admin_dashboard_detail_container"), function(){
                            _positionIndicator($(".js-dashboard_section_indicator.second_level"), $(".js-admin_dashboard_column.detail nav.section_nav a[href=#admin-users-genealogy]"));
                            
                            //load user genealogy info
                            _getTemplate("/templates/admin/users/genealogy/_downline.handlebars.html",_data.currentUser.downline, $(".js-genealogy-summary_downline"));
                            _getTemplate("/templates/admin/users/genealogy/_upline.handlebars.html",_data.currentUser.upline, $(".js-genealogy-summary_upline"));
                        });
                break;

            }
            if(typeof _callback === "function") _callback();

        }


        function getGenealogy(_options){
            ["val=ancestors", "val=children"].forEach(function(_criteria){
                if(_getObjectsByCriteria(_data.currentUser, _criteria).length>0){
                    _ajax({
                        _ajaxType:"get",
                        _url:_getObjectsByCriteria(_data.currentUser, _criteria)[0].href,
                        _callback:function(data, text){
                            _genealogyData = {};
                            _getObjectsByCriteria(data, "key=first_name").forEach(function(member, index){_genealogyData[index]=member;});
                            if(_criteria==="val=children") _data.currentUser.downline=_genealogyData;
                            else _data.currentUser.upline=_genealogyData;
                            if(!!_options && typeof _options._callback === "function" && _criteria==="val=children") _options._callback();
                        }
                    });
                }
            })
        }

        //* start admin adshboard specific utility functions 
        function switchCurrentUser(e){
            e.preventDefault();
            var _userID;
            _userID= $(e.target)[0].tagName.toLowerCase()==="select"? parseInt($(e.target).val().replace("#","")) : parseInt($(e.target).attr("href").replace("#",""));
            if(!!_userID){
                _ajax({
                    _ajaxType:"get",
                    _url:"/a/users/"+_userID,
                    _callback:function(data, text){
                        _data.currentUser= _getObjectsByCriteria(data, "key=address")[0];
                        _dashboard.displayUsers("#admin-users-membership");
                    }
                });
            }
        }

        function switchCurrentProduct(e){
            e.preventDefault();
            var _productID;
            _productID= $(e.target)[0].tagName.toLowerCase()==="select"? parseInt($(e.target).val().replace("#","")) : parseInt($(e.target).attr("href").replace("#",""));
            if(!!_productID){
                _ajax({
                    _ajaxType:"get",
                    _url:"/a/products/"+_productID,
                    _callback:function(data, text){
                        _data.currentProduct= data;
                        displayPlans("#admin-plans-products");
                    }
                });
            }
        }

        function searchUser(_queryString){
            _ajax({
                _ajaxType:"get",
                _url:"/a/users",
                _postObj:{q:_queryString},
                _callback:function(data, text){
                    data.queryString=_queryString;
                    console.log("search for "+_queryString);
                    data.queryString=_queryString;
                    _displaySearchResults(data);
                }
            });
        }

        function _displaySearchResults(_dataObj){
            var _results = {};
            var _displayData = {};
            _getObjectsByCriteria(_dataObj, "key=first_name").forEach(function(_result, _index){_results[_index]=_result});
            _displayData.totalFound = _getObjectsByCriteria(_dataObj, "key=first_name").length;
            _displayData.queryString = _dataObj.queryString;
            _displayData.results = _results;

            $(".js-admin_dashboard_column.summary").animate({opacity:0});
             _getTemplate("/templates/admin/users/search/_nav.handlebars.html", {}, $(".js-admin_dashboard_column.detail .section_nav"), function(){
                _positionIndicator($(".js-dashboard_section_indicator.second_level"), $(".js-admin_dashboard_column.detail nav.section_nav a[href=#admin-users-search-results]"));

            }); 
            _getTemplate("/templates/admin/users/search/_results.handlebars.html", _displayData, $(".js-admin_dashboard_detail_container"));
             $(".js-admin_dashboard_column.summary").css("display","none");
             $(".js-admin_dashboard_column.detail").animate({width:"1216px"});

            $(document).on("click", ".js-search_result", function(e){
                e.preventDefault();
                _getTemplate("/templates/admin/users/_nav.handlebars.html", {}, $(".js-admin_dashboard_column.detail .section_nav"));
                $(".js-admin_dashboard_column.summary").html("");
                $(".js-admin_dashboard_column.detail").css({width:"960px", opacity:0});
                 $(".js-admin_dashboard_column.summary").css("display","block");
                switchCurrentUser(e);
                $(".js-admin_dashboard_column.summary, .js-admin_dashboard_column.detail").animate({opacity:1});
            });
        }


        function _populateReferencialSelect(_options){
            //locate any "select"'s and determine the dropdown display options needed for them
            _options._popupData.fields.forEach(function(field){
                //populate secondary selection options 
                if(field.type === "select"){
                    field.displayOptions=[];
                    if(typeof field.options !== "undefined") delete field.options["_path"];
                    if(field.name=="type") field.displayOptions.push({name:"Select a Qualification Type", value:"none"});

                    if(typeof field.reference !== "undefined"){
                        //query specific options
                        if(field.reference.rel === "products"){
                            _data.products.entities.forEach(function(_product){
                                field.displayOptions.push({name:_product.properties.name, value:_product.properties.id});
                            });
                        }
                        if(field.reference.rel === "ranks"){
                            _data.ranks.entities.forEach(function(_rank){
                                field.displayOptions.push({name:_rank.properties.id+", "+_rank.properties.title, value:_rank.properties.id});
                                //console.log(_rank.properties.title);
                            });
                        }

                    }else{
                        //object specific options
                        for(var key in field.options){
                            field.displayOptions.push({name:field.options[key], value:key});
                        }
                    }
                }
            });
        }

        function _displayPopup(_options){
            $("#js-popup").css({"left":(($(window).width()/2)-240)+"px","top":"150px", opacity:0});
            $("#js-popup").animate({opacity:1, top:"+=30"}, 200);
            $(".js-popup_form_button").on("click", function(e){
                e.preventDefault();
                _ajax({
                    _ajaxType:_options._popupData.method,
                    _url:_options._popupData.href,
                    _postObj: $("#js-popup_form").serializeObject(),
                    _callback:function(data, text){
                        $("#js-screen_mask").click();
                        if(typeof _options._callback === "function") _options._callback();
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
                        _secondaryOptions=[];
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
                $(".js-percentage_container").each(function(){
                    var _rankID = (parseInt($(this).attr("data-amount-array-index"))+_amountDetail.first);
                    var _rankTitle = _getObjectsByCriteria(_data.ranks.entities, {id:_rankID}).filter(function(_rank){return typeof _rank.title!=="undefined"})[0].title;
                    var _barWidth = $(this).width();
                    $(this).find(".js-percentage_label").html(_rankID+", "+_rankTitle+": "+($(this).attr("data-amount-percentage")*100).toFixed(0)+"% <span style='font-size:10px;'>$"+($(this).attr("data-amount-percentage")*_amountDetail.total).toFixed(0)+"</span>");
                    $(this).find(".js-percentage_bar").animate({"width":(_barWidth*$(this).attr("data-amount-percentage")).toFixed(0)+"px"},300);
                });

                $(".js-percentage_container").on("mousemove", function(e){
                    e.preventDefault();
                    var _barWidth = $(this).width();
                    var _position = {x: e.pageX - $(this).offset().left, y: e.pageY - $(this).offset().top}
                    var _percentage = (_position.x/_barWidth).toFixed(2);
                    var _rankID = (parseInt($(this).attr("data-amount-array-index"))+_amountDetail.first);
                    var _rankTitle = _getObjectsByCriteria(_data.ranks.entities, {id:_rankID}).filter(function(_rank){return typeof _rank.title!=="undefined"})[0].title;
                    if(_percentage>=_amountDetail.max) _percentage=_amountDetail.max;
                    $(this).find(".js-percentage_label").html(_rankID+", "+_rankTitle+": ["+(_percentage*100).toFixed(0)+"%] [$"+(_percentage*_amountDetail.total).toFixed(0)+"]");
                    $(this).find(".js-percentage_label").css("color","#ddd");
                });

                $(".js-percentage_container").on("mouseout", function(e){
                    e.preventDefault();
                    var _rankID = (parseInt($(this).attr("data-amount-array-index"))+_amountDetail.first);
                    var _rankTitle = _getObjectsByCriteria(_data.ranks.entities, {id:_rankID}).filter(function(_rank){return typeof _rank.title!=="undefined"})[0].title;
                    $(this).find(".js-percentage_label").html(_rankID+", "+_rankTitle+": "+($(this).attr("data-amount-percentage")*100).toFixed(0)+"% <span style='font-size:10px;'>$"+($(this).attr("data-amount-percentage")*_amountDetail.total).toFixed(0)+"</span>");
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


                $(".js-update_bonus_payment").on("click", function(e){
                    e.preventDefault();
                    var _amounts=[];
                     $(".js-percentage_container").each(function(){
                        _amounts.push(parseFloat($(this).attr("data-amount-percentage")));
                     });
                    _ajax({
                        _ajaxType:_options._popupData.method,
                        _url:_options._popupData.href,
                        _postObj: {amounts:_amounts},
                        _callback:function(data, text){
                            $("#js-screen_mask").click();
                            if(typeof _options._callback === "function") _options._callback();
                        }
                    });
                });

            }


            if(_options._popupData.deleteOption){
                //delete entities
                $(".js-delete").on("click", function(e){
                    e.preventDefault();
                    console.log(_options._popupData.href);
                    _ajax({
                        _ajaxType:"delete",
                        _url:_options._popupData.href,
                        _callback:function(data, text){
                            $("#js-screen_mask").click();
                            if(typeof _options._callback === "function") _options._callback();
                        }
                    });
                });
            }
        }

        function _positionIndicator(_indicatorObj, _highlightObj){
            if( _indicatorObj.position().left== (_highlightObj.position().left+(_highlightObj.width()/2)-10)) return;

            _highlightObj.parent().find("a").removeClass("js-active");
            _highlightObj.addClass("js-active");
            _indicatorObj.css("left", (_highlightObj.position().left+(_highlightObj.width()/2)-10)+"px");
            _indicatorObj.css("top", (_highlightObj.position().top+(_highlightObj.height() + 20 ))+"px");
            _indicatorObj.animate({"top":"-=15", "opacity":1}, 300);
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

        $(document).on("click", "#js-screen_mask", function(e){
            if(!$(e.target).attr("id") || $(e.target).attr("id")!=="js-screen_mask") return;
            $("#js-popup").animate({opacity:0, top:"-=50"},200, function(){
                $("#js-screen_mask").fadeOut(100, function(){
                    $("#js-popup").remove();
                });                
            });
            return;

        });        

        $(window).resize(function(){
            $("#js-popup").css({"left":(($(window).width()/2)-240)+"px","top":"200px"});
            //%TODO: recalculate x position for the indicators
        })

        //* end admin adshboard specific utility functions


    }//end AdminDashboard class

});