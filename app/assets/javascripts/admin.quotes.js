//admin.js

var _data={};
var _dashboard;
_data.loadCategories=["quotes", "orders", "pay_periods"];

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
        if(_loading) _data.loadTimer = setTimeout(_data.load, 100);
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
            _dashboard._loadOrdersInfo();
            _dashboard._loadPayPeriodsInfo();

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
    $(document).on("click", ".section_nav a", function(e){_dashboard.displayQuotes($(e.target).attr("href"));});

    function AdminDashboard(){
        this.displayQuotes = displayQuotes;
        this._loadQuotesInfo = _loadQuotesInfo;
        this._loadOrdersInfo = _loadOrdersInfo;
        this._loadPayPeriodsInfo = _loadPayPeriodsInfo;


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
                    $(".js-search_box").fadeIn();

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

                    _displayData=(_data.quotes.search.results.entities.length>0)? _data.quotes.search.results : _data.quotes;
                    _displayData.paginationInfo= _paginateData(_getObjectsByCriteria(_displayData, {name:"page"})[0], {prefix:"js-quotes", actionableCount:10});



                    _getTemplate("/templates/admin/quotes/quotes/_quotes.handlebars.html", _displayData, $(".js-admin_dashboard_detail_container"), function(){
                        $(".js-admin_dashboard_detail_container, .js-admin_dashboard_column.summary").animate({"opacity":1});

                        //wire up search quotes 
                        $(".js-search_box").on("click", function(e){e.preventDefault();});
                        $(".js-search_box").on("keypress", function(e){
                            if(e.keyCode == 13){
                                if(($(e.target).val().trim().length>0) && ($(e.target).val().trim().length<3)) return;
                                _data.quotes.search={};
                                _data.quotes.search.term=$(e.target).val().trim();
                                _searchQuotes(e, function(){displayQuotes("#admin-quotes-quotes")});
                            }
                        });


                        $(".js-pagination a").on("click", function(e){
                            e.preventDefault();
                            _searchQuotes(e, function(){displayQuotes("#admin-quotes-quotes")});
                        });


                        //wire up convert quotes to order
                        $(".js-convert_quote_to_order").on("click", function(e){
                            e.preventDefault();
                            _quote = EyeCueLab.JSON.getObjectsByPattern(
                                _data.quotes, {
                                "containsIn(properties)":[{id:$(e.target).parents("tr").attr("data-quote-id")}], 
                                "containsIn(links)":[{rel:"self"}]
                            })[0];

                            //fetch detail
                            _ajax({
                                _ajaxType:"get",
                                _url:_getObjectsByCriteria(_quote, {rel: "self"})[0].href,
                                _callback:function(data, text){
                                    var _dataObj = (typeof _getObjectsByCriteria(data, {name: "create_order"})[0] === "object")? _getObjectsByCriteria(data, {name: "create_order"})[0]:{};
                                    var _popupData = _formatPopupData(e, {
                                        _dataObj: _dataObj,
                                        _title: "Quote Details"
                                    });
                                    _popupData.properties = data.properties;
                                    _popupData.distributorInfo =  EyeCueLab.JSON.getObjectsByPattern(
                                        data, {
                                        "containsIn(class)":["user"], 
                                        "containsIn(rel)":["quote-user"]
                                    })[0];

                                    _popupData.customerInfo = EyeCueLab.JSON.getObjectsByPattern(
                                        data, {
                                        "containsIn(class)":["customer"], 
                                        "containsIn(rel)":["quote-customer"]
                                    })[0];

                                    _popupData.productInfo =  EyeCueLab.JSON.getObjectsByPattern(
                                        data, {
                                        "containsIn(class)":["product"], 
                                        "containsIn(rel)":["quote-product"]
                                    })[0];

                                    ["_path","id"].forEach(function(_hideKey){
                                        delete _popupData.distributorInfo.properties[_hideKey];
                                        delete _popupData.customerInfo.properties[_hideKey];
                                        delete _popupData.productInfo.properties[_hideKey];
                                    });

                                    $("#js-screen_mask").fadeIn(100, function(){
                                        _getTemplate("/templates/admin/quotes/popups/_quote_to_order_popup_container.handlebars.html",_popupData, $("#js-screen_mask"), function(){
                                            _displayPopup({_popupData:_popupData, _callback:function(){displayQuotes("#admin-quotes-quotes-init")}});
                                        });
                                    });
                                }
                            });
                        })
                    });
                 break;
                

                case "#admin-quotes-orders-init":
                    _loadOrdersInfo(function(){displayQuotes("#admin-quotes-orders");});
                break;

                case "#admin-quotes-orders":
                    $(".js-search_box").fadeIn();
                    $(".js-admin_dashboard_detail_container, .js-admin_dashboard_column.summary").css("opacity",0);
                    //position indicator
                    _getTemplate("/templates/admin/quotes/_nav.handlebars.html", {}, $(".js-admin_dashboard_column.detail .section_nav"), function(){
                        _positionIndicator($(".js-dashboard_section_indicator.second_level"), $(".js-admin_dashboard_column.detail nav.section_nav a[href=#admin-quotes-orders-init]"));
                        if((!!_data.orders.search) && (!!_data.orders.search.results)) $(".js-search_box").val(_data.orders.search.term);
                    });

                    if(!_data.orders.search){
                        _data.orders.search={};
                        _data.orders.search.term="";
                        _data.orders.search.results={};
                        _data.orders.search.results.entities=[];
                    }

                    _getTemplate("/templates/admin/quotes/orders/_summary.handlebars.html", {}, $(".js-admin_dashboard_column.summary"), function(){
                        if(!_data.orders.sortBy) _data.orders.sortBy = "created";
                        else{
                             $(".js-orders_sort_type option").each(function(){
                                if(this.value === _data.orders.sortBy) $(".js-orders_sort_type").val(this.value);
                             })
                        }
                        $(".js-orders_sort_type").on("change", function(e){
                            _data.orders.sortBy=$(e.target).val();
                            _searchOrders(e, function(){displayQuotes("#admin-quotes-orders")});
                        });
                    });                

                    _displayData=(_data.orders.search.results.entities.length>0)? _data.orders.search.results : _data.orders;
                    _displayData.paginationInfo= _paginateData(_getObjectsByCriteria(_displayData, {name:"page"})[0], {prefix:"js-orders", actionableCount:10});


                    _getTemplate("/templates/admin/quotes/orders/_orders.handlebars.html", _displayData, $(".js-admin_dashboard_detail_container"), function(){
                        $(".js-admin_dashboard_detail_container, .js-admin_dashboard_column.summary").animate({"opacity":1});
                        $(".js-search_box").on("click", function(e){e.preventDefault();});
                        $(".js-search_box").on("keypress", function(e){
                            if(e.keyCode == 13){
                                if(($(e.target).val().trim().length>0) && ($(e.target).val().trim().length<3)) return;
                                _data.orders.search={};
                                _data.orders.search.term=$(e.target).val().trim();
                                _searchOrders(e, function(){displayQuotes("#admin-quotes-orders")});
                            }
                        });
                        //pagination
                        $(".js-pagination a").on("click", function(e){
                            e.preventDefault();
                            _searchOrders(e, function(){displayQuotes("#admin-quotes-orders")});
                        });
                    });

                break;

                case "#admin-quotes-pay-periods-init":
                    _loadPayPeriodsInfo(function(){displayQuotes("#admin-quotes-pay-periods");});

                break;

                case "#admin-quotes-pay-periods":

                    $(".js-admin_dashboard_detail_container, .js-admin_dashboard_column.summary").css("opacity",0);
                    //position indicator
                    _getTemplate("/templates/admin/quotes/_nav.handlebars.html", {}, $(".js-admin_dashboard_column.detail .section_nav"), function(){
                        _positionIndicator($(".js-dashboard_section_indicator.second_level"), $(".js-admin_dashboard_column.detail nav.section_nav a[href=#admin-quotes-pay-periods-init]"));
                    });
                    
                    _getTemplate("/templates/admin/quotes/pay_periods/_summary.handlebars.html", {}, $(".js-admin_dashboard_column.summary"), function(){
                    });
                    _displayData={};
                    $.extend(true, _displayData , _data.pay_periods);
                    _displayData.entities.forEach(function(entity){
                        var t = entity.properties.start_date;
                        entity.properties.startDisplayDate=new Date(parseInt(t.split("-")[0]),parseInt(t.split("-")[1])-1,parseInt(t.split("-")[2])).toDateString(); 
                        t = entity.properties.end_date;
                        entity.properties.endDisplayDate = new Date(parseInt(t.split("-")[0]),parseInt(t.split("-")[1])-1,parseInt(t.split("-")[2])).toDateString(); 
                    });
                    _getTemplate("/templates/admin/quotes/pay_periods/_pay_periods.handlebars.html", _displayData, $(".js-admin_dashboard_detail_container"), function(){
                        $(".js-admin_dashboard_detail_container, .js-admin_dashboard_column.summary").animate({"opacity":1});
                        $(".js-search_box").fadeOut(200);
                        //wiire up calculationg/recalculation button
                        $(".js-calculate_pay_period").on("click", function(e){
                            e.preventDefault();
                            var _pay_period_id= $(e.target).parents("tr").attr("data-pay-period-id");
                            _calculatePayPeriod(EyeCueLab.JSON.getObjectsByPattern(_data.pay_periods, {"containsIn(properties)":[_pay_period_id]})[0], function(){displayQuotes("#admin-quotes-pay-periods-init")});
                        });

                        //pay period details
                        $(".js-pay_period_link").on("click", function(e){
                            e.preventDefault();
                            var _pay_period_id = $(e.target).parents("tr").attr("data-pay-period-id");
                            var _pay_period_obj = EyeCueLab.JSON.getObjectsByPattern(_data.pay_periods, {"containsIn(properties)":[_pay_period_id]})[0];
                            //gather info for the pay period
                            _ajax({
                                _ajaxType:"get",
                                _url:_getObjectsByCriteria(_pay_period_obj, {rel:"self"})[0].href,
                                _callback:function(data, text){
                                    var _order_total_url = EyeCueLab.JSON.getObjectsByPattern(data.entities, {"containsIn(class)":["list", "order_totals"]})[0].href
                                    EyeCueLab.JSON.asynchronousLoader([_order_total_url], function(_returnJSONs){
                                        var _order_total_obj = EyeCueLab.JSON.getObjectsByPattern(_returnJSONs, {"containsIn(class)":["list", "order_totals"]})[0];
                                        var _popupData= _order_total_obj;
                                        var t = _pay_period_obj.properties.start_date;

                                        _pay_period_obj.properties.startDisplayDate=new Date(parseInt(t.split("-")[0]),parseInt(t.split("-")[1])-1,parseInt(t.split("-")[2])).toDateString(); 
                                        t = _pay_period_obj.properties.end_date;
                                        _pay_period_obj.properties.endDisplayDate = new Date(parseInt(t.split("-")[0]),parseInt(t.split("-")[1])-1,parseInt(t.split("-")[2])).toDateString(); 
                                        _popupData.pay_period = _pay_period_obj.properties;
                                        _popupData.title="Pay Period Detail";
                                        _popupData.paginationInfo=_paginateData(_getObjectsByCriteria(_order_total_obj, {name:"page"})[0], {prefix:"js-popup", actionableCount:10});
                                        _popupData.paginationInfo.templateName="/templates/admin/quotes/popups/_order_total_listing.handlebars.html",
                                        _popupData.paginationInfo.templateContainer="#js-popup .js-popup_content_container";

                                        $("#js-screen_mask").fadeIn(100, function(){
                                            _getTemplate("/templates/admin/quotes/popups/_pay_periods_container.handlebars.html",_popupData, $("#js-screen_mask"), function(){
                                                $("#js-popup").css("opacity","0");
                                                _getTemplate("/templates/admin/quotes/popups/_order_total_listing.handlebars.html",_popupData, $("#js-popup .js-popup_content_container"), function(){
                                                    _displayPopup({_popupData:_popupData, _css:{width:1000} });

                                                });
                                            });
                                        });
                                    });
                                }
                            }); //end of pay period detail
                        });
                    });

                break;

            }
        }

        function _calculatePayPeriod(_pay_period, _callback){
            var _action=_getObjectsByCriteria(_pay_period, "val~calculate")[0];
            $("#js-screen_mask").fadeIn(100, function(){
                _getTemplate("/templates/admin/quotes/popups/_processing_popup.handlebars.html",{title:"Please Wait", instructions:"The calculation may take a few moments to complete. Thakn you!"}, $("#js-screen_mask"), function(){
                    _displayPopup({_popupData:{}});
                    _ajax({
                        _ajaxType:_action.method,
                        _url:_action.href,
                        _callback:function(data, text){
                            $("#js-screen_mask").fadeOut(100);
                            $("body").css("overflow", "auto");
                            if(typeof _callback == "function") _callback();
                            else return data;
                        }
                    });
                });
            });
        }


        function _searchQuotes(e, _callback){
            _data.quotes.search.page= $(e.target).attr("data-page-number")? $(e.target).attr("data-page-number").split(" ")[1]:1;
            _ajax({
                _ajaxType:"get",
                _url:"/a/quotes",
                _postObj:{
                    search:_data.quotes.search.term,
                    sort:_data.quotes.sortBy,
                    page:_data.quotes.search.page
                },
                _callback:function(data, text){
                    _data.quotes.search.results=data;
                    _data.quotes.search.results.entities.forEach(function(_quote){
                        _quote.properties._dataStatusDisplay = _quote.properties.data_status.toString();
                        _d = new Date(_quote.properties.created_at);
                        _quote.properties.localDateString = _d.toLocaleDateString();
                    });
                    if(typeof _callback == "function") _callback();
                    else return data;
                }
            });
        }

       function _searchOrders(e, _callback){
            _data.orders.search.page= $(e.target).attr("data-page-number")? $(e.target).attr("data-page-number").split(" ")[1]:1;
            _ajax({
                _ajaxType:"get",
                _url:"/a/orders",
                _postObj:{
                    search:_data.orders.search.term,
                    sort:_data.orders.sortBy,
                    page:_data.orders.search.page
                },
                _callback:function(data, text){
                    _data.orders.search.results=data;
                    _data.orders.search.results.entities.forEach(function(_order){
                        _d = new Date(_order.properties.order_date);
                        _order.properties.localDateString = _d.toLocaleDateString();
                    });
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
                var _action = _getObjectsByCriteria(_options._popupData.actions, {name:"index"})[0];
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
                    if(_callback !== undefined) _callback();
                    return;
                }
            });
        }

        function _loadQuotesInfo(_callback){
            _ajax({
                _ajaxType:"get",
                _url:"/a/quotes",
                _callback:function(data, text){
                    _data.quotes = data;
                    _data.quotes.entities.forEach(function(_quote){
                        _d = new Date(_quote.properties.created_at);
                        _quote.properties.localDateString = _d.toLocaleDateString();
                        _quote.properties._dataStatusDisplay = _quote.properties.data_status.toString();
                    });
                    if(typeof _callback === "function") _callback();
                }
            });
        }

        function _loadOrdersInfo(_callback, _options){
            var _postObj=(_options && _options._postObj)?_options._postObj:{};
            _ajax({
                _ajaxType:"get",
                _url:"/a/orders",
                _postObj:_postObj,
                _callback:function(data, text){
                    _data.orders = data;
                    _data.orders.entities.forEach(function(_quote){
                        _d = new Date(_quote.properties.order_date);
                        _quote.properties.localDateString = _d.toLocaleDateString();
                    });
                    if(typeof _callback === "function") _callback();
                }
            });
        }

        function _loadPayPeriodsInfo(_callback, _options){
            var _postObj=(_options && _options._postObj)?_options._postObj:{};

            _ajax({
                _ajaxType:"get",
                _url:"/a/pay_periods",
                _postObj:_postObj,
                _callback:function(data, text){
                    _data.pay_periods = data;
                    /*_data.orders.entities.forEach(function(_quote){
                        _d = new Date(_quote.properties.order_date);
                        _quote.properties.localDateString = _d.toLocaleDateString();
                    });*/

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
            $("#js-popup").css({"left":(($(window).width()/2)-($("#js-popup").width()/2))+"px","top":"200px"});
            //%TODO: recalculate x position for the indicators
        })

        //* end admin adshboard specific utility functions


    }//end AdminDashboard class

});