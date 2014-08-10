//admin.js

var _data={};
var _dashboard;
_data.loadCategories=["quotes"];

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
            _dashboard.displayQuotes("#admin-quotes-init");
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
            _dashboard._loadQuotesInfo();
        }
    });

    $(document).on("click", ".admin_top_level_nav", function(e){
        switch($(e.target).attr("href").replace("#admin-","")){
            case "users":
                window.location="/a/users";
            break;

            case "plans":
                window.location="/a/products";
            break;
        }
    });
    $(document).on("click", ".section_nav a", function(e){_dashboard.displayPlans($(e.target).attr("href"));});


    function AdminDashboard(){
        this.displayPlans = displayPlans;
        this.displayQuotes = displayQuotes;

        this._loadQuotesInfo = _loadQuotesInfo;


        function displayQuotes(_tab, _callback){
            switch(_tab){
                case "#admin-quotes-init":
                    $(".js-dashboard_section_indicator.top_level").css("left", ($("#header_container nav a[href=#admin-quotes]").position().left+28)+"px");
                    $(".js-dashboard_section_indicator.top_level").animate({"top":"-=15", "opacity":1}, 300);
                    displayQuotes("#admin-quotes-quotes");

                break;

                case "#admin-quotes-quotes-init":
                    _loadQuotesInfo(function(){displayQuotes("#admin-quotes-quotes");});
                break;

                case "#admin-quotes-quotes":
                    $(".js-admin_dashboard_detail_container, .js-admin_dashboard_column.summary").css("opacity",0);
                    //position indicator
                    _getTemplate("/templates/admin/quotes/_nav.handlebars.html", {}, $(".js-admin_dashboard_column.detail .section_nav"), function(){
                        _positionIndicator($(".js-dashboard_section_indicator.second_level"), $(".js-admin_dashboard_column.detail nav.section_nav a[href=#admin-quotes-quotes]"));

                        if((!!_data.quotes.search) && (!!_data.quotes.search.results)) $(".js-search_box").val(_data.quotes.search.term);
                    });

                    if(!_data.quotes.search){
                        _data.quotes.search={};
                        _data.quotes.search.term="";
                        _data.quotes.search.results={};
                        _data.quotes.search.results.entities=[];
                    }
                    
                    _getTemplate("/templates/admin/quotes/quotes/_summary.handlebars.html", {}, $(".js-admin_dashboard_column.summary"), function(){
                        if(!_data.quotes.sortBy) _data.quotes.sortBy = "created";
                        else{
                             $(".js-quotes_sort_type option").each(function(){
                                if(this.value === _data.quotes.sortBy) $(".js-quotes_sort_type").val(this.value);
                             })
                        }
                        $(".js-quotes_sort_type").on("change", function(e){
                            _data.quotes.sortBy=$(e.target).val();
                            _searchQuotes(e, function(){displayQuotes("#admin-quotes-quotes")});
                        });
                    });

                    _data.quotes.entities.forEach(function(_quote){
                        _quote.properties._dataStatusDisplay = _quote.properties.data_status.toString();
                    });
                    _data.quotes.search.results.entities.forEach(function(_quote){
                        _quote.properties._dataStatusDisplay = _quote.properties.data_status.toString();
                    });

                    _displayData=(_data.quotes.search.results.entities.length>0)? _data.quotes.search.results : _data.quotes;

                    _getTemplate("/templates/admin/quotes/quotes/_quotes.handlebars.html", _displayData, $(".js-admin_dashboard_detail_container"), function(){
                        $(".js-admin_dashboard_detail_container, .js-admin_dashboard_column.summary").animate({"opacity":1});

                        $(".js-search_box").on("click", function(e){e.preventDefault();});
                        $(".js-search_box").on("keypress", function(e){
                            if(e.keyCode == 13){
                                if(($(e.target).val().trim().length>0) && ($(e.target).val().trim().length<3)) return;
                                _data.quotes.search={};
                                _data.quotes.search.term=$(e.target).val().trim();
                                _searchQuotes(e, function(){displayQuotes("#admin-quotes-quotes")});
                            }
                        });
                    });
                 break;

                case "#admin-quotes-sales":
                break;
            }
        }

        function _searchQuotes(e, _callback){
            _ajax({
                _ajaxType:"get",
                _url:"/a/quotes",
                _postObj:{
                    search:$(e.target).val().trim(),
                    sort:_data.quotes.sortBy,
                },
                _callback:function(data, text){
                    _data.quotes.search.results=data;
                    if(typeof _callback == "function") _callback();
                    else return data;
                }
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