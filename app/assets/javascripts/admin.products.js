//admin.js

var _data={};
var _dashboard;

jQuery(function($){

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
                _dashboard.displayPlans("#admin-plans-init");
            }});
        }
    });

    $(document).on("click", ".admin_top_level_nav", function(e){
        window.location=($(e.target).attr("href").replace("#admin-","")=="plans")?"/a/products":"/a/users";
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
                    displayPlans("#admin-plans-ranks-init");

                break;

                case "#admin-plans-ranks-init":
                    if(typeof _data.products === "undefined"){
                        _ajax({
                            _ajaxType:"get",
                            _url:"/a/products",
                            _callback:function(data, text){
                                _data.products = data;
                                _data.currentProduct=data.entities[0];
                            }
                        });
                    }
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

                                })

                            });
                            displayPlans("#admin-plans-ranks");
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
                        //wire up new rank functionality
                        $(".js-add_new_rank").on("click", function(e){
                            e.preventDefault();
                            if(!_getObjectsByCriteria(_data.ranks.actions, "val=create").length) return;
                            var _popupData = [];
                            _popupData = _getObjectsByCriteria(_data.ranks.actions, "val=create")[0];
                            _popupData.fields.forEach(function(field){field.display_name=field.name.replace(/\_/g," ");});
                            _popupData.title="Add a new Rank";

                            $("#js-screen_mask").fadeIn(100, function(){
                                _getTemplate("/templates/admin/plans/products/popup/_new_rank.handlebars.html",_popupData, $("#js-screen_mask"), function(){
                                    _displayPopup({_popupData:_popupData, _callback:function(){displayPlans("#admin-plans-ranks-init")}});
                                });
                            });
                        });
                    });

                    _getTemplate("/templates/admin/plans/ranks/_ranks.handlebars.html", _data.ranks, $(".js-admin_dashboard_detail_container"), function(){
                        $(".js-admin_dashboard_detail_container, .js-admin_dashboard_column.summary").animate({"opacity":1});
                        //load qualifications
                        for(var _rank in _data.qualifications){
                            var _row =  $(".js-admin_dashboard_detail_container table tr[data-rank-id="+_rank+"]");

                            for(_qualification_path in _data.qualifications[_rank]){
                                _qualification_group=_data.qualifications[_rank][_qualification_path];
                                _qualification_group.forEach(function(_qualification){
                                    _row.find(".js-qualification_path").html("Path: "+_qualification_path);
                                    _row.find(".js-qualification_type").append("<div class='innerCell'><span class='label'> Product:"+_qualification.properties.type.replace(/\_/g," ")+"</span>"+_qualification.properties.type.replace(/\_/g," ")+"</div><br style='clear:both;'>");
                                    _conditions=[];
                                    for(var _p in _qualification.properties){
                                        switch (_p){
                                            case "_path": case "path": case "type":
                                            break;
                                            default:
                                                _conditions.push( "<div class='innerCell'>"+("<span class='label'>"+_p+"</span>"+_qualification.properties[_p]).replace(/\_/g," ")+"</div>");
                                            break;
                                        }
                                    }
                                    _conditions.sort();
                                    _conditions.reverse();
                                    _row.find(".js-qualification_conditions").append(_conditions.join("")+"<br style='clear:both;'>");
                                    _row.find(".js-qualification_actions").append("<div class='innerCell' style='vertical-align:middle;'>Edit | Remove</div><br style='clear:both;'>");
                                });
                            };
                        };
                        //wire up rank edit
                        $(".js-rank_link").on("click", function(e){
                            e.preventDefault();
                            _rankID = parseInt($(e.target).attr("href").replace("#",""));                 
                            _ajax({
                                _ajaxType:"get",
                                _url:"/a/ranks/"+_rankID,
                                _callback:function(data, text){
                                    var _popupData = [];
                                    _popupData = _getObjectsByCriteria(data, "val=update")[0];
                                    _popupData.fields.forEach(function(field){field.display_name=field.name.replace(/\_/g," ");});
                                    _popupData.title="Editing Rank "+data.properties.id+", "+data.properties.title;
                                    _popupData.deleteOption={};
                                    _popupData.id=_rankID;
                                    _popupData.deleteOption.name="Remove "+data.properties.id+", "+data.properties.title;
                                    
                                    if(_data.ranks.entities.length == _rankID) _popupData.deleteOption.buttonName="js-delete_rank";
                                    _popupData.deleteOption.description="Only the highest Rank can be removed at this time";

                                    $("#js-screen_mask").fadeIn(100, function(){
                                        _getTemplate("/templates/admin/plans/products/popup/_new_rank.handlebars.html",_popupData, $("#js-screen_mask"), function(){
                                            _displayPopup({_popupData:_popupData, _callback:function(){displayPlans("#admin-plans-ranks-init")}});
                                        });
                                    });
                                }
                            });
                        });

                        //wire up ability to add qualifications
                        $(".js-add_qualification").on("click", function(e){
                            e.preventDefault();
                            _rankID = parseInt($(e.target).parents("tr").attr("data-rank-id"));
                            _ajax({
                                _ajaxType:"get",
                                _url:"/a/ranks/"+_rankID,
                                _callback:function(data, text){
                                    var _popupData = [];
                                    _popupData =_getObjectsByCriteria(data, "val~qualification").filter(function(action){return action.name=="create"})[0];
                                    _popupData.fields.forEach(function(field){field.display_name=field.name.replace(/\_/g," ");});
                                    _popupData.id=_rankID;
                                    _popupData.popupType = "hierarchical";
                                    _popupData.rootOptions=[];
                                    ["path", "type"].forEach(function(rootOption){
                                         _popupData.rootOptions.push(_getObjectsByCriteria(_popupData.fields,{name:rootOption})[0]); 
                                    });

                                    _popupData.title="Add a New Qualification<br>for Rank "+data.properties.id+", "+data.properties.title;

                                    $("#js-screen_mask").fadeIn(100, function(){
                                        _getTemplate("/templates/admin/plans/products/popup/_new_qualification.handlebars.html",_popupData, $("#js-screen_mask"), function(){
                                            _displayPopup({_popupData:_popupData, _callback:function(){displayPlans("#admin-plans-ranks-init")}});
                                        });
                                    });
                                }
                            });
                        })

                    });

                break;

                case "#admin-plans-products-init":
                    if(typeof _data.products === "undefined"){
                        _ajax({
                            _ajaxType:"get",
                            _url:"/a/products",
                            _callback:function(data, text){
                                _data.products = data;
                                _data.currentProduct=data.entities[0];
                                displayPlans("#admin-plans-products");
                            }
                        });
                    }
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
                    _getTemplate("/templates/admin/plans/products/_summary.handlebars.html", _summaryData, $(".js-admin_dashboard_column.summary"));
                    _getTemplate("/templates/admin/plans/products/_products.handlebars.html", _data.currentProduct, $(".js-admin_dashboard_detail_container"), function(){
                        $(".js-admin_dashboard_detail_container, .js-admin_dashboard_column.summary").animate({"opacity":1});
                        $(".js-product_select option[value="+_data.currentProduct.properties.id+"]").attr("selected", "selected");
                        //wire up edit product button
                        //%TODO: move the summary function within the summary _getTemplate block instead of the products main pane block
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
                                        _getTemplate("/templates/admin/plans/products/popup/_new_product.handlebars.html",_popupData, $("#js-screen_mask"), function(){
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
                                _getTemplate("/templates/admin/plans/products/popup/_new_product.handlebars.html",_popupData, $("#js-screen_mask"), function(){
                                    _displayPopup({_popupData:_popupData, _callback:function(){displayPlans("#admin-plans-products")}});
                                });
                            });
                        });

                        //wire up product switching control
                        $(".js-product_select").on("change", function(e){
                            switchCurrentProduct(e);
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

        function _displayPopup(_options){
            console.log("show popup " + _options._popupData.href);
            $("#js-popup").css({"left":(($(window).width()/2)-240)+"px","top":"150px", opacity:0});
            $("#js-popup").animate({opacity:1, top:"+=30"}, 200);
            $(".js-popup_form_button").on("click", function(e){
                e.preventDefault();
                _ajax({
                    _ajaxType:_options._popupData.method,
                    _url:_options._popupData.href,
                    _postObj: $("#js-popup_form").serializeObject(),
                    _callback:function(data, text){
                        console.log(_options._callback);
                        $("#js-screen_mask").click();
                        if(typeof _options._callback === "function") _options._callback();
                    }
                });
            });

            //wire up dynamic interaction for the select/option
            if(_options._popupData.popupType === "hierarchical"){
                $("#js-popup_form .js-popup_form_button").css("display","none");
                _options._popupData.rootOptions.forEach(function(_rootOption){
                    if(_rootOption.type == "select"){
                        $("#js-popup_form .rootOptions select[name="+_rootOption.name+"]").on("change", function(e){
                            $("#js-popup_form .js-popup_form_button").css("display","none");
                            $("#js-popup_form .secondaryOptions").html("");
                            if($(e.target).val()==="none") return;
                            _secondaryOptions=[];
                            _options._popupData.fields.forEach(function(field){
                                if(!!field.visibility && 
                                    field.visibility.control==_rootOption.name && 
                                    field.visibility.values.indexOf($(e.target).val())>=0){
                                        //populate secondary selection options 
                                        if(field.type === "select"){
                                            field.displayOptions=[];
                                            if(typeof field.reference !== "undefined"){
                                                //query specific options
                                                if(field.reference.rel === "products"){
                                                    _data.products.entities.forEach(function(_product){
                                                        field.displayOptions.push({name:_product.properties.name, value:_product.properties.id});
                                                    });
                                                }
                                            }else{
                                                //object specific options
                                                delete field.options._path;
                                                for(var key in field.options){
                                                    field.displayOptions.push({name:field.options[key], value:key});
                                                }
                                            }
                                        }
                                        _secondaryOptions.push(field);

                                }
                            });
                            _getTemplate("/templates/admin/plans/products/popup/_secondary_options.handlebars.html", _secondaryOptions, $("#js-popup_form .secondaryOptions"), function(){
                                $("#js-popup_form .js-popup_form_button").fadeIn();

                            });
                        })
                    }
                });

                //populate the initial input for the first select/option value
                //_options._popupData
                //$("#js-popup_form .secondaryOptions")
            }


            //%TODO: consolidate delete actions using _popupData.id so that all delete actions are unified
            if(_options._popupData.deleteOption){
                //delete product
                $(".js-delete.js-delete_product").on("click", function(e){
                    e.preventDefault();
                    _ajax({
                        _ajaxType:"delete",
                        _url:"/a/products/"+_data.currentProduct.properties.id,
                        _callback:function(data, text){
                            $("#js-screen_mask").click();
                            if(typeof _options._callback === "function") _options._callback();
                        }
                    })
                });
                //delete ranks
                $(".js-delete.js-delete_rank").on("click", function(e){
                    e.preventDefault();
                    _ajax({
                        _ajaxType:"delete",
                        _url:"/a/ranks/"+_options._popupData.id,
                        _callback:function(data, text){
                            $("#js-screen_mask").click();
                            if(typeof _options._callback === "function") _options._callback();
                        }
                    })
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