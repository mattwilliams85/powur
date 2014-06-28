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
            _dashboard.getUsers({_callback:function(){
                _data.currentUser=_data.rootUsers[0];
                _dashboard.displayUsers("#admin-users-init");
                //adjust dashboard pointer 
                $(".js-dashboard_section_indicator.top_level").css("left", ($("#header_container nav a[href=#admin-users]").position().left+28)+"px");
                $(".js-dashboard_section_indicator.top_level").animate({"top":"-=15", "opacity":1}, 300);

                //navigation init
                $(document).on("click", "nav.section_nav a, nav.section_subnav a", function(e){
                    e.preventDefault();
                    _dashboard.displayUsers($(this).attr("href"));
                });

                //user link init (context switching)
                $(document).on("click", ".js-user_link", function(e){
                    e.preventDefault();
                    var _userID;
                    _userID=parseInt($(e.target).attr("href").replace("#",""));
                    if(!!_userID){
                        _ajax({
                            _ajaxType:"get",
                            _url:"/a/users/"+_userID,
                            _callback:function(data, text){
                                _data.currentUser= _getObjectsByCriteria(data, "key=address")[0];
                                _dashboard.displayUsers("#admin-users-membership")
                            }
                        })
                    }
                })

            }});
        }
    });




    function AdminDashboard(){
        this.getUsers = getUsers;
        this.displayUsers = displayUsers;

        //function get root users if _id is undefined
        //otherwise get specific user info
        function getUsers(_options){
            if (typeof _options._id === "undefined"){
                _ajax({
                    _ajaxType:"get",
                    _url:"/a/users",
                    _callback:function(data, text){
                        _getObjectsByCriteria(data, "key=first_name").forEach(function(user){_data.rootUsers.push(user);});
                        if(typeof _options._callback === "function") _options._callback();
                    }
                });

                return _data.rootUsers;
            }
        }

        function displayUsers(_tab){
            console.log(_tab);
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

                            _getTemplate("/templates/admin/users/membership/_summary.handlebars.html", _data.currentUser, $(".js-admin_dashboard_column.summary"));

                            //prepare for summary information
                            _getTemplate("/templates/admin/users/membership/_detail_container.handlebars.html", _data.currentUser, $(".js-admin_dashboard_detail_container"), function(){

                                _positionIndicator($(".js-dashboard_section_indicator.second_level"), $(".js-admin_dashboard_column.detail nav.section_nav a[href=#admin-users-membership]"));

                                //load basic_info information 
                                $(".js-admin_dashboard_detail").fadeOut(100, function(){
                                    _getTemplate("/templates/admin/users/membership/_basic_info.handlebars.html", _data.currentUser,  $(".js-admin_dashboard_detail"));
                                    $(".js-admin_dashboard_detail").fadeIn(300);
                                });
                            });

                        }
                    });
                break;

                case "#admin-users-membership-pay_out_history":
                    $(".js-admin_dashboard_detail_container").fadeOut(100, function(){
                        _getTemplate("/templates/admin/users/membership/_pay_out_history.handlebars.html", _data.currentUser,  $(".js-admin_dashboard_detail"), function(){
                            $(".js-admin_dashboard_detail").fadeIn(300);
                        });
                    });
                break;

               case "#admin-users-genealogy":
                        _getTemplate("/templates/admin/users/genealogy/_summary.handlebars.html", _data.currentUser,  $(".js-admin_dashboard_detail_container"), function(){
                            _positionIndicator($(".js-dashboard_section_indicator.second_level"), $(".js-admin_dashboard_column.detail nav.section_nav a[href=#admin-users-genealogy]"));
                            
                            //load user genealogy info
                            ["val=ancestors", "val=children"].forEach(function(_criteria){
                                if(_getObjectsByCriteria(_data.currentUser, _criteria).length>0){
                                    _ajax({
                                        _ajaxType:"get",
                                        _url:_getObjectsByCriteria(_data.currentUser, _criteria)[0].href,
                                        _callback:function(data, text){
                                            if(  _getObjectsByCriteria(data, "key=first_name").length==0) return;
                                            _genealogyData = {};
                                            _getObjectsByCriteria(data, "key=first_name").forEach(function(recruit, index){_genealogyData[index]=recruit;});
                                            if(_criteria==="val=children")
                                                _getTemplate("/templates/admin/users/genealogy/_downline.handlebars.html",_genealogyData, $(".js-genealogy-summary_downline"));
                                            else
                                                _getTemplate("/templates/admin/users/genealogy/_upline.handlebars.html",_genealogyData, $(".js-genealogy-summary_upline"));
                                        }
                                    });
                                }                                
                            })

                            //load downline info
                            /*
                            if(_getObjectsByCriteria(_data.currentUser, "val=children").length>0){
                                _ajax({
                                    _ajaxType:"get",
                                    _url:_getObjectsByCriteria(_data.currentUser, "rel=children")[0].href,
                                    _callback:function(data, text){
                                        _downlineData = {};
                                        _getObjectsByCriteria(data, "key=first_name").forEach(function(recruit, index){_downlineData[index]=recruit;});
                                        _getTemplate("/templates/admin/users/genealogy/_downline.handlebars.html",_downlineData, $(".js-genealogy-summary_downline"));

                                    }
                                });
                            }*/

                        });
                break;

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


    }//end AdminDashboard class

});