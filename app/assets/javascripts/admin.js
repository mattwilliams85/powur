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
                _dashboard.displayUsers("init");
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
                        _getObjectsByCriteria(data, "key=first_name").forEach(function(user){
                            _data.rootUsers.push(user);
                        });
                        if(typeof _options._callback === "function") _options._callback();
                    }
                });
                return _data.rootUsers;
            }
        }

        function displayUsers(_tab){
            console.log(_data.currentUser);
            switch(_tab){
                case "membership":
                case "init":
                    _ajax({
                        _ajaxType:"get",
                        _url:"/a/users/"+_data.currentUser.id,
                        _callback:function(data, text){
                            _thisUser= _getObjectsByCriteria(data, "key=address")[0];
                            if(_tab==="init"){    
                                _thisUser.userDropDown=[];
                                _data.rootUsers.forEach(function(rootUser){
                                    if(typeof rootUser !== "undefined"){
                                        _thisUser.userDropDown.push({
                                            first_name:rootUser.first_name, 
                                            last_name:rootUser.last_name,
                                            id:rootUser.id
                                        });
                                    }
                                });
                            }
                            _getTemplate("/templates/admin/users/membership/_summary.handlebars.html", _thisUser, $(".js-admin_dashboard_column.summary"));
                        }
                    })
                break;
            }

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