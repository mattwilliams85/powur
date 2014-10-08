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
                _dashboard.displayUsers("#admin-users-init");
            }});
        }
    });

    $(document).on("click", ".admin_top_level_nav", function(e){
        $(".admin_top_level_nav").removeClass("active");
        if($(e.target).attr("href").replace("#admin-","")=="plans") window.location="/a/products";
        if($(e.target).attr("href").replace("#admin-","")=="quotes") window.location="/a/quotes";

    });



    function AdminDashboard(){
        this.getRootUsers = getRootUsers;
        this.getGenealogy = getGenealogy;
        this.displayUsers = displayUsers;
        this.switchCurrentUser = switchCurrentUser;
        this.searchUser = searchUser;

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

        function displayUsers(_tab, _options){

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
                    $(".js-update_distributor_info").on("click" , function(e){
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

                    //TODO: wire up  force rank override button
                    //

                break;



                case "#admin-users-sales":
                case "#admin-users-sales-orders":
                    _getTemplate("/templates/admin/users/sales/_summary.handlebars.html", _data.currentUser,  $(".js-admin_dashboard_detail_container"), function(){
                        _positionIndicator($(".js-dashboard_section_indicator.second_level"), $(".js-admin_dashboard_column.detail nav.section_nav a[href=#admin-users-sales]"));
                        var _endPoints =[];
                        _endPoints.push({
                            url:EyeCueLab.JSON.getObjectsByPattern(_data.currentUser.actions, {"containsIn(class)":["list", "orders"]})[0].href,
                            data:{}
                        });
                        _endPoints.push({
                            url:EyeCueLab.JSON.getObjectsByPattern(_data.currentUser.actions, {"containsIn(class)":["list", "order_totals"]})[0].href,
                            data:{}
                        });

                        EyeCueLab.JSON.asynchronousLoader(_endPoints, function(_returnJSONs){
                            var _displayData={};
                            $.extend(true, _displayData, EyeCueLab.JSON.getObjectsByPattern(_returnJSONs, {"containsIn(class)":["list", "orders"]})[0]);
                            _displayData.entities.forEach(function(_entity){
                                _d = new Date(_entity.properties.order_date);
                                _entity.properties.localDateString = _d.toLocaleDateString();
                            });
                            _getTemplate("/templates/admin/users/sales/_orders.handlebars.html",_displayData,  $(".js-admin_dashboard_detail"), function(){
                                console.log(_displayData);
                                /*$(".js-order_details").on("click", function(e){
                                    e.preventDefault();
                                    var _url=$(this).attr("data-detail-href");
                                    _ajax({
                                        _ajaxType:"get",
                                        _url:_url,
                                        _callback:function(data){
                                            _popupData = data;
                                            _popupData.title="Order Details";
                                            _popupData.productInfo = EyeCueLab.JSON.getObjectsByPattern(data, {"containsIn(class)":["product"]})[0];
                                            _popupData.customerInfo = EyeCueLab.JSON.getObjectsByPattern(data, {"containsIn(class)":["customer"]})[0];
                                            _popupData.userInfo = EyeCueLab.JSON.getObjectsByPattern(data, {"containsIn(class)":["user"]})[0];

                                            console.log(_popupData);

                                            $("#js-screen_mask").fadeIn(100, function(){
                                                _getTemplate("/templates/admin/users/sales/popups/_order_details.handlebars.html",_popupData, $("#js-screen_mask"), function(){
                                                    _displayPopup({_popupData:_popupData});
                                                });
                                            });
                                        }
                                    });
                                });*/

                                $(".js-order_details").on("click", function(e){
                                    e.preventDefault();
                                    var _url=$(this).attr("data-detail-href");
                                    _ajax({
                                        _ajaxType:"get",
                                        _url:_url,
                                        _callback:function(data){
                                            _popupData = data;
                                            _popupData.title="Order Details";
                                            _popupData.productInfo = EyeCueLab.JSON.getObjectsByPattern(data, {"containsIn(class)":["product"]})[0];
                                            _popupData.customerInfo = EyeCueLab.JSON.getObjectsByPattern(data, {"containsIn(class)":["customer"]})[0];
                                            _popupData.userInfo = EyeCueLab.JSON.getObjectsByPattern(data, {"containsIn(class)":["user"]})[0];
                                            
                                            var _endpoints=[];

                                            if(typeof EyeCueLab.JSON.getObjectsByPattern(data, {"containsIn(class)":["bonus_payments"]})[0]!=="undefined") _endpoints.push({
                                                    url:EyeCueLab.JSON.getObjectsByPattern(data, {"containsIn(class)":["bonus_payments"]})[0].href,
                                                    data:{}
                                                })

                                            if(typeof _getObjectsByCriteria(data, {"rel":"ancestors"}) !=="undefined" ) _endpoints.push({
                                                    url:_getObjectsByCriteria(data, {"rel":"ancestors"})[0].href,
                                                    data:{}
                                                });
                                            EyeCueLab.JSON.asynchronousLoader(_endpoints, function(_returnJSONs){
                                                _popupData.uplineInfo = EyeCueLab.JSON.getObjectsByPattern(_returnJSONs, {"containsIn(class)":["list","users"]})[0];
                                                _popupData.bonusInfo = EyeCueLab.JSON.getObjectsByPattern(_returnJSONs, {"containsIn(class)":["list","bonus_payments"]})[0];
                                                $("#js-screen_mask").fadeIn(100, function(){
                                                    _getTemplate("/templates/admin/users/sales/popups/_order_details.handlebars.html",_popupData, $("#js-screen_mask"), function(){
                                                        _displayPopup({_popupData:_popupData, _css:{width:800}});
                                                        console.log(_popupData);
                                                    });
                                                });


                                            })
                                        }
                                    });
                                });
                            });      
                        });
                    });

                break;


                case "#admin-users-sales-order_totals":
                    _getTemplate("/templates/admin/users/sales/_summary.handlebars.html", _data.currentUser,  $(".js-admin_dashboard_detail_container"), function(){
                        _positionIndicator($(".js-dashboard_section_indicator.second_level"), $(".js-admin_dashboard_column.detail nav.section_nav a[href=#admin-users-sales]"));
                        $(".section_subnav a").removeClass("js-active");                        
                        $(".section_subnav a:eq(1)").addClass("js-active");
                        var _endPoints =[];
                        _endPoints.push({
                            url:EyeCueLab.JSON.getObjectsByPattern(_data.currentUser.actions, {"containsIn(class)":["list", "orders"]})[0].href,
                            data:{}
                        });
                        _endPoints.push({
                            url:EyeCueLab.JSON.getObjectsByPattern(_data.currentUser.actions, {"containsIn(class)":["list", "order_totals"]})[0].href,
                            data:{}
                        });
                        EyeCueLab.JSON.asynchronousLoader(_endPoints, function(_returnJSONs){
                            var _displayData={};
                            $.extend(true, _displayData, EyeCueLab.JSON.getObjectsByPattern(_returnJSONs, {"containsIn(class)":["list", "order_totals"]})[0]);
                            _getTemplate("/templates/admin/users/sales/_order_totals.handlebars.html",_displayData,  $(".js-admin_dashboard_detail"), function(){
                                console.log(_displayData);
                            });      
                        });
                    });

                break;

                case "#admin-users-sales-rank_achievements":
                    _getTemplate("/templates/admin/users/sales/_summary.handlebars.html", _data.currentUser,  $(".js-admin_dashboard_detail_container"), function(){
                        _positionIndicator($(".js-dashboard_section_indicator.second_level"), $(".js-admin_dashboard_column.detail nav.section_nav a[href=#admin-users-sales]"));
                        $(".section_subnav a").removeClass("js-active");                        
                        $(".section_subnav a:eq(2)").addClass("js-active");
                        var _endPoints =[];
                        var _filtering_obj = (typeof _options === "undefined")?{}:_options._filtering_obj;
                        _endPoints.push({
                            url:EyeCueLab.JSON.getObjectsByPattern(_data.currentUser.actions, {"containsIn(class)":["list", "rank_achievements"]})[0].href,
                            data:{}
                        });
                        _endPoints.push({
                            url:"/a/pay_periods",
                            data:{}
                        });
                        EyeCueLab.JSON.asynchronousLoader(_endPoints, function(_returnJSONs){
                            var _displayData={};
                            $.extend(true, _displayData, EyeCueLab.JSON.getObjectsByPattern(_returnJSONs, {"containsIn(class)":["list", "rank_achievements"]})[0]);
                            _displayData.pay_period=EyeCueLab.JSON.getObjectsByPattern(_returnJSONs, {"containsIn(class)":["list", "pay_periods"]})[0];
                            _getTemplate("/templates/admin/users/sales/_rank_achievements.handlebars.html",_displayData,  $(".js-admin_dashboard_detail"), function(){
                                console.log(_displayData);
                                $("#js-pay_period_select").on("change", function(e){
                                    e.preventDefault();
                                    displayUsers("#admin-users-sales-rank_achievements", {_filtering_obj:{pay_period:$(this).val()}});
                                })
                            });      
                        });
                    });
                break;

                case "#admin-users-sales-bonus_payments":
                    _getTemplate("/templates/admin/users/sales/_summary.handlebars.html", _data.currentUser,  $(".js-admin_dashboard_detail_container"), function(){
                        _positionIndicator($(".js-dashboard_section_indicator.second_level"), $(".js-admin_dashboard_column.detail nav.section_nav a[href=#admin-users-sales]"));
                        $(".section_subnav a").removeClass("js-active");                        
                        $(".section_subnav a:eq(3)").addClass("js-active");
                        var _endPoints =[];
                        var _filtering_obj = (typeof _options === "undefined")?{}:_options._filtering_obj;
                        _endPoints.push({
                            url:EyeCueLab.JSON.getObjectsByPattern(_data.currentUser.actions, {"containsIn(class)":["list", "bonus_payments"]})[0].href,
                            data:_filtering_obj
                        });
                        _endPoints.push({
                            url:"/a/pay_periods",
                            data:{}
                        });

                        EyeCueLab.JSON.asynchronousLoader(_endPoints, function(_returnJSONs){
                            var _displayData={};
                            $.extend(true, _displayData, EyeCueLab.JSON.getObjectsByPattern(_returnJSONs, {"containsIn(class)":["list", "bonus_payments"]})[0]);
                            _displayData.pay_period=EyeCueLab.JSON.getObjectsByPattern(_returnJSONs, {"containsIn(class)":["list", "pay_periods"]})[0];
                            _getTemplate("/templates/admin/users/sales/_bonus_payments.handlebars.html",_displayData,  $(".js-admin_dashboard_detail"), function(){
                                console.log(_displayData);
                                $("#js-pay_period_select").on("change", function(e){
                                    e.preventDefault();
                                    displayUsers("#admin-users-sales-bonus_payments", {_filtering_obj:{pay_period:$(this).val()}});
                                })

                            });      
                        });
                    });
                break;


                case "#admin-users-genealogy":
                    _getTemplate("/templates/admin/users/genealogy/_summary.handlebars.html", _data.currentUser,  $(".js-admin_dashboard_detail_container"), function(){
                        _positionIndicator($(".js-dashboard_section_indicator.second_level"), $(".js-admin_dashboard_column.detail nav.section_nav a[href=#admin-users-genealogy]"));
                        
                        //load user genealogy info
                        //upline links
                        _getTemplate("/templates/admin/users/genealogy/_downline.handlebars.html",_data.currentUser.downline, $(".js-genealogy-summary_downline"), function(){
                            $(".js-user_link").on("click", function(e){
                                e.preventDefault();
                                _dashboard.switchCurrentUser(e);
                            });
                        });

                        //downline links
                        _getTemplate("/templates/admin/users/genealogy/_upline.handlebars.html",_data.currentUser.upline, $(".js-genealogy-summary_upline"), function(){
                            $(".js-user_link").on("click", function(e){
                                e.preventDefault();
                                _dashboard.switchCurrentUser(e);
                            });                                
                        });
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
                _postObj:{search:_queryString},
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

            _getTemplate("/templates/admin/users/search/_results.handlebars.html", _displayData, $(".js-admin_dashboard_detail_container"), function(){
                $(".js-admin_dashboard_column.summary").css("display","none");
                $(".js-admin_dashboard_column.detail").animate({width:"1216px"});
                $(".js-admin_dashboard_column.detail").animate({width:"1216px"});
            });

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

            if(!_options._css) _options._css={};
            if(!_options._css.width) _options._css.width=480;
            if(!_options._css.maxHeight) _options._css.maxHeight = $(window).height()-400;
            if(!_options._css.opacity) _options._css.opacity=0;
            if(!_options._css.top) _options._css.top=150;
            $("#js-popup").css("height","auto");
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

            if(_options._popupData.deleteOption){
                $(".js-delete.js-delete_product").on("click", function(){
                    _ajax({
                        _ajaxType:"delete",
                        _url:"/a/products/"+_data.currentProduct.properties.id,
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




        $(document).on("click", "#js-screen_mask", function(e){
            if(!$(e.target).attr("id") || $(e.target).attr("id")!=="js-screen_mask") return;
            $("#js-popup").animate({opacity:0, top:"-=50"},200, function(){
                $("#js-screen_mask").fadeOut(100, function(){
                    $("#js-popup").remove();
                });                
            });
            return;

        });        

        //wire up navigation 
        $(document).on("click", "nav.section_nav a, nav.section_subnav a", function(e){
            e.preventDefault();
            _dashboard.displayUsers($(this).attr("href"));
        });

        //wire up additional logic to allow switching of current user (that you are looking at)
        $(document).on("click", ".js-user_link", function(e){
            e.preventDefault();
            _dashboard.switchCurrentUser(e);
        });

        $(document).on("change", ".js-user_select", function(e){
            e.preventDefault();
            _dashboard.switchCurrentUser(e);
        });        

        $(document).on("keypress", ".js-search_box" , function(e){
            if(e.keyCode == 13){
                console.log($(e.target).val())
                _dashboard.searchUser($(e.target).val());
            }
        });


        $(window).resize(function(){
            $("#js-popup").css({"left":(($(window).width()/2)-240)+"px","top":"200px"});
            //todo: recalculate x position for the indicators
        })

        //* end admin adshboard specific utility functions


    }//end AdminDashboard class

});