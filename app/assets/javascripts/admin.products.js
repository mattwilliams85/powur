//admin.js

var _data={};
var _dashboard;
_data.loadCategories=["products", "ranks", "qualifications", "active_qualifications", "active_qualification_paths", "bonuses", "bonus_plans_loaded", "quotes"];

jQuery(function($){

    _data.loadTimer="";
    _data.load = function(){
        var _loading=false;
        for(i=0; i<_data.loadCategories.length;i++){
            if(typeof _data[_data.loadCategories[i]] === "undefined"){
                console.log("loading: global data... "+_data.loadCategories[i]);

                _loading=true;
                break;
            }
        }
        if(_loading) _data.loadTimer = setTimeout(_data.load, 10);
        else{
            clearTimeout(_data.loadTimer);
            for(i=0; i<_data.loadCategories.length;i++){
                console.log("complete: global data... "+_data.loadCategories[i]);
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

            _dashboard._loadBonusPlansInfo();
            _dashboard._loadProductsInfo();
            _dashboard._loadRanksInfo();
            _dashboard._loadQuotesInfo();
        }
    });

    $(document).on("click", ".admin_top_level_nav", function(e){
        switch($(e.target).attr("href").replace("#admin-","")){
            case "users":
                window.location="/a/users";
            break;

            case "quotes":
                window.location="/a/quotes";
            break;
        }
    });
    $(document).on("click", ".section_nav a", function(e){_dashboard.displayPlans($(e.target).attr("href"));});


    function AdminDashboard(){
        this.displayPlans = displayPlans;

        this._loadBonusPlansInfo = _loadBonusPlansInfo;
        this._loadProductsInfo = _loadProductsInfo;
        this._loadRanksInfo = _loadRanksInfo;
        this._loadQuotesInfo = _loadQuotesInfo;


        function displayPlans(_tab, _callback){
            switch(_tab){

                case "#admin-plans-init":
                    $(".js-dashboard_section_indicator.top_level").css("left", ($("#header_container nav a[href=#admin-plans]").position().left+28)+"px");
                    $(".js-dashboard_section_indicator.top_level").animate({"top":"-=15", "opacity":1}, 300);
                    displayPlans("#admin-plans-ranks");

                break;

                case "#admin-plans-ranks-init":
                    //refresh rank qualifications
                    _loadRanksInfo(function(){displayPlans("#admin-plans-ranks");});
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
                    _loadProductsInfo(function(){displayPlans("#admin-plans-products");});
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
                        //wire up new product button
                        $(".js-add_new_product").on("click", function(e){
                            if(!_getObjectsByCriteria(_data.products, "val=create").length) return;
                            var _popupData = _formatPopupData(e, {
                                _dataObj: _getObjectsByCriteria(_data.products, "val=create")[0],
                                _title: "Create a new Product"
                            });                            

                            $("#js-screen_mask").fadeIn(100, function(){
                                _getTemplate("/templates/admin/plans/popups/_standard_popup_container.handlebars.html",_popupData, $("#js-screen_mask"), function(){
                                    _displayPopup({_popupData:_popupData, _callback:function(){displayPlans("#admin-plans-products-init")}});
                                });
                            });
                        });
                    });

                    _getTemplate("/templates/admin/plans/products/_products.handlebars.html", _data.products, $(".js-admin_dashboard_detail_container"), function(){
                        $(".js-admin_dashboard_detail_container, .js-admin_dashboard_column.summary").animate({"opacity":1});
                        $(".js-product_select option[value="+_data.currentProduct.properties.id+"]").attr("selected", "selected");
                        
                        //edit product
                        $( ".js-edit_product").on("click", function(e){
                            e.preventDefault();
                            var _actionObj=EyeCueLab.JSON.getObjectsByPattern(_data.products, {
                                "containsIn(properties)":[{id:$(e.target).parents("tr").attr("data-product-id")}],
                                "containsIn(class)"     :["product"]
                            })[0];

                            _ajax({
                                _ajaxType:"get",
                                _url:_actionObj.links.filter(function(_link){return _link.rel=="self"})[0].href,
                                _callback:function(data, text){
                                    var _popupData = _formatPopupData(e, {
                                        _dataObj: _getObjectsByCriteria(data, "val=update")[0],
                                        _title: "Editing "+data.properties.name,
                                        _deleteOption: {
                                            name: "Remove "+data.properties.name,
                                            buttonName: "js-delete_product",
                                            description: "When you remove a product, all compensation calculation will be removed immediately.  Please exercise with caution."
                                        }
                                    });      

                                    $("#js-screen_mask").fadeIn(100, function(){
                                        _getTemplate("/templates/admin/plans/popups/_standard_popup_container.handlebars.html",_popupData, $("#js-screen_mask"), function(){
                                            _displayPopup({_popupData:_popupData, _callback:function(){displayPlans("#admin-plans-products-init")}});
                                        });
                                    });
                                }
                            });

                        });
                    });
                break;

                case "#admin-plans-bonuses-init":
                    _loadBonusPlansInfo(function(){displayPlans("#admin-plans-bonuses");})
                break;

                case "#admin-plans-bonuses":
                    $(".js-admin_dashboard_detail_container, .js-admin_dashboard_column.summary").css("opacity",0);
                    //position indicator
                    _getTemplate("/templates/admin/plans/_nav.handlebars.html", {}, $(".js-admin_dashboard_column.detail .section_nav"), function(){
                        _positionIndicator($(".js-dashboard_section_indicator.second_level"), $(".js-admin_dashboard_column.detail nav.section_nav a[href=#admin-plans-bonuses]"));
                    });

                    _summaryData={};
                    $.extend(true, _summaryData, _data.bonus_plans);
                    _summaryData.currentBonusPlan={};
                    $.extend(true, _summaryData.currentBonusPlan, _data.currentBonusPlan);
                    _getTemplate("/templates/admin/plans/bonuses/_summary.handlebars.html", _summaryData, $(".js-admin_dashboard_column.summary"), function(){
                        //add a new bonus to a plan
                        $(".js-add_new_bonus").on("click", function(e){
                            var _popupData = _formatPopupData(e, {
                                _dataObj: _getObjectsByCriteria(_data.bonuses.actions, {name:"create"})[0],
                                _title: "Create a new Bonus"
                            });
                            _populateReferencialSelect({_popupData:_popupData});

                            $("#js-screen_mask").fadeIn(100, function(){
                                _getTemplate("/templates/admin/plans/popups/_standard_popup_container.handlebars.html",_popupData, $("#js-screen_mask"), function(){
                                    _displayPopup({ _popupData:_popupData, _callback:function(){displayPlans("#admin-plans-bonuses-init")}});
                                });
                            }); 
                        });

                        //add a new bonus plan
                        $(".js-add_new_bonus_plan").on("click", function(e){
                            var _popupData = _formatPopupData(e, {
                                _dataObj: _getObjectsByCriteria(_data.bonus_plans.actions, {name:"create"})[0],
                                _title: "Create a new Bonus Plan"
                            });
                            $("#js-screen_mask").fadeIn(100, function(){
                                _getTemplate("/templates/admin/plans/popups/_standard_popup_container.handlebars.html",_popupData, $("#js-screen_mask"), function(){
                                    _displayPopup({_popupData:_popupData, _callback:function(){displayPlans("#admin-plans-bonuses-init")}});
                                });
                            }); 
                        });

                        //edit an existing bonus plan
                        $(".js-edit_bonus_plan").on("click", function(e){
                            var _popupData = _formatPopupData(e, {
                                _dataObj: _getObjectsByCriteria(_data.currentBonusPlan, {href:$(".js-bonus_plan_select").val()}).filter(function(_obj){return _obj.name=="update"})[0],
                                _title: "Edit "+_data.currentBonusPlan.properties.name,
                                _deleteOption: {
                                    name: "Remove "+_data.currentBonusPlan.properties.name,
                                    buttonName: "js-delete_bonus_plan",
                                    description: "WARNING: Removing an existing bonus plan is highly discouraged.  Please exercise this option with extreme caution."
                                }


                            });
                            $("#js-screen_mask").fadeIn(100, function(){
                                _getTemplate("/templates/admin/plans/popups/_standard_popup_container.handlebars.html",_popupData, $("#js-screen_mask"), function(){
                                    _displayPopup({_popupData:_popupData, _callback:function(){displayPlans("#admin-plans-bonuses-init")}});
                                });
                            }); 
                        });
                        //switch current bonus plan
                        $(".js-bonus_plan_select").on("change", function(e){
                            e.preventDefault();
                            _data.currentBonusPlan ={};
                            _data.bonuses={};
                            $.extend(true, _data.currentBonusPlan, _getObjectsByPath(_data.bonus_plans, _getObjectsByCriteria(_data.bonus_plans, {href:$(e.target).val()})[0]._path, -2));
                            $.extend(true, _data.bonuses, _data.currentBonusPlan.bonuses);
                            displayPlans("#admin-plans-bonuses");
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
                                                _display+="<div class='innerCell'><span class='label'>"+_rankID+", "+_rankTitle+"</span><span class='super'>"+(_amount*100).toFixed(1)+"% <span class='sub'>$"+(_amount*_amountDetail.total).toFixed(2)+"</span></span></div>";

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
            if(!_options._css) _options._css={};
            if(!_options._css.width) _options._css.width=480;
            if(!_options._css.maxHeight) _options._css.maxHeight = $(window).height()-400;
            if(!_options._css.opacity) _options._css.opacity=0;
            if(!_options._css.top) _options._css.top=150;
            $("body").css("overflow", "hidden");

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
                    }

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


        //loadBonusPlan Data
        function _loadBonusPlansInfo(_callback){
            _ajax({
                _ajaxType:"get",
                _url:"/a/bonus_plans",
                _callback:function(data, text){
                    var _bonus_plans_loaded = 0;
                    _data.bonus_plans = data;
                    _data.bonus_plans.entities.forEach(function(_bonus_plan){
                        //get bonus_plan detail
                        _ajax({
                            _ajaxType:"get",
                            _url:_getObjectsByCriteria(_bonus_plan, {rel:"self"})[0].href.toString(),
                            _callback:function(data, text){
                                $.extend(true, _bonus_plan, data);

                                //get bonuses associated with the plan
                                _ajax({
                                    _ajaxType:"get",
                                    _url:_getObjectsByPath(_bonus_plan, _getObjectsByCriteria(_bonus_plan, "val=bonuses")[0]._path, -1).href,
                                    _callback:function(data, text){
                                        _bonus_plan.bonuses={};
                                        $.extend(true, _bonus_plan.bonuses, data);
                                        _bonus_plans_loaded+=1;

                                        //load all bonus details for each plan
                                        var _bonus_detail_loaded=0;
                                        if(_bonus_plan.bonuses.entities.length>0){
                                            //if there are bonuses
                                            _bonus_plan.bonuses.entities.forEach(function(_bonus){
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
                                                        _bonus_detail_loaded +=1;

                                                        console.log("loading: bonus detail... \""+ _bonus_plan.properties.name+ "\" > \""+_bonus.properties.name+"\" ("+_bonus_detail_loaded+" of "+_bonus_plan.bonuses.entities.length+")");
                                                        
                                                        //check if last of the plan and the last of the bonus in the plan are both loaded
                                                        if((_bonus_detail_loaded == _bonus_plan.bonuses.entities.length) && (_bonus_plans_loaded ==  _data.bonus_plans.entities.length)){
                                                            console.log("complete: bonus plans... \""+ _bonus_plan.properties.name+ "\"");
                                                            _data.bonus_plans_loaded=true;

                                                            // first time loading will default the selected plan to the currently active one
                                                            if(_bonus_plan.properties.active==true && !_data.currentBonusPlan) {
                                                                _data.currentBonusPlan= _bonus_plan;
                                                                _data.bonuses= _bonus_plan.bonuses;
                                                            }
                                                            else if((!!_data.currentBonusPlan)&& (_data.currentBonusPlan.links[0].href== _bonus_plan.links[0].href)){
                                                                _data.bonuses={};
                                                                _data.currentBonusPlan={};
                                                                $.extend(true, _data.currentBonusPlan, _bonus_plan);
                                                                $.extend(true, _data.bonuses, _bonus_plan.bonuses);
                                                            }
                                                            if(typeof _callback === "function") _callback();
                                                        }
                                                    }
                                                });
                                            });//end bonus requirements
                                        }
                                        else if((_bonus_plans_loaded == _data.bonus_plans.entities.length)){
                                            //check if last of the plan and the last of the bonus in the plan are both loaded
                                            console.log("loading: bonus detail... \""+ _bonus_plan.properties.name+ "\" > None ("+_bonus_detail_loaded+" of "+_bonus_plan.bonuses.entities.length+")");

                                            console.log("complete: bonus plans... \""+ _bonus_plan.properties.name+ "\"");
                                            _data.bonus_plans_loaded=true;

                                            // first time loading will default the selected plan to the currently active one
                                            if(_bonus_plan.properties.active==true && !_data.currentBonusPlan) {
                                                _data.currentBonusPlan= _bonus_plan;
                                                _data.bonuses= _bonus_plan.bonuses;
                                            }
                                            else if((!!_data.currentBonusPlan)&& (_data.currentBonusPlan.links[0].href== _bonus_plan.links[0].href)){
                                                _data.bonuses={};
                                                _data.currentBonusPlan={};
                                                $.extend(true, _data.currentBonusPlan, _bonus_plan);
                                                $.extend(true, _data.bonuses, _bonus_plan.bonuses);
                                            }

                                            if(typeof _callback === "function") _callback();
                                        }
                                    }
                                });//end bonuses details within a bonus_plan
                            }
                        });// end bonuses list within a bonus_plan
                    });// end bonus_plans details
                }// end bonus_plans list
            });
        }//end _loadBonusPlans

        function _loadProductsInfo(_callback){
            _ajax({
                _ajaxType:"get",
                _url:"/a/products",
                _callback:function(data, text){
                    _data.products = data;
                    _data.currentProduct=data.entities[0];
                    if(typeof _callback === "function") _callback();
                }
            });
        }

        function _loadRanksInfo(_callback){
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
                            if(typeof _callback === "function") _callback();
                        }
                    });
                }
            });
        }

        function _loadQuotesInfo(_callback){
            _ajax({
                _ajaxType:"get",
                _url:"/a/quotes",
                _callback:function(data, text){
                    _data.quotes = data;
                    if(typeof _callback === "function") _callback();
                }
            });
        }


        $(document).on("click", "#js-screen_mask", function(e){
            if(!$(e.target).attr("id") || $(e.target).attr("id")!=="js-screen_mask") return;
            $("#js-popup").animate({opacity:0, top:"-=50"},200, function(){
                $("#js-screen_mask").fadeOut(100, function(){
                    $("#js-popup").remove();
                    $("body").css("overflow","auto");
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