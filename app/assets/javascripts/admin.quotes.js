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
                    EyeCueLab.UX.getTemplate("/templates/admin/quotes/_nav.handlebars.html", {}, $(".js-admin_dashboard_column.detail .section_nav"), function(){
                        SunStand.Admin.positionIndicator($(".js-dashboard_section_indicator.second_level"), $(".js-admin_dashboard_column.detail nav.section_nav a[href=#admin-quotes-quotes]"));
                        if((!!_data.quotes.filterObj.search)) $(".js-search_box").val(_data.quotes.filterObj.search);
                    });


                    EyeCueLab.UX.getTemplate("/templates/admin/quotes/quotes/_summary.handlebars.html", {}, $(".js-admin_dashboard_column.summary"), function(){
                        
                        if(!_data.quotes.filterObj.page)_data.quotes.filterObj.page=1;
                        if(!_data.quotes.filterObj.sort)_data.quotes.filterObj.sort = "created";
                        
                        $(".js-quotes_sort_type option").each(function(){
                            if(this.value === _data.quotes.filterObj.sort) $(".js-quotes_sort_type").val(this.value);
                        })

                        $(".js-quotes_sort_type").on("change", function(e){
                            _data.quotes.filterObj.sort=$(this).val();
                            _loadQuotesInfo(function(){displayQuotes("#admin-quotes-quotes");});
                        });
                    });

                    var _displayData=_data.quotes;
                    _displayData.paginationInfo= SunStand.UX.paginateData(_getObjectsByCriteria(_displayData, {name:"page"})[0], {prefix:"js-quotes", actionableCount:10});


                    EyeCueLab.UX.getTemplate("/templates/admin/quotes/quotes/_quotes.handlebars.html", _displayData, $(".js-admin_dashboard_detail_container"), function(){
                        $(".js-admin_dashboard_detail_container, .js-admin_dashboard_column.summary").animate({"opacity":1});

                        //wire up search quotes
                        $(".js-search_box").on("click", function(e){e.preventDefault();});
                        $(".js-search_box").on("keypress", function(e){
                            if(e.keyCode == 13){
                                if(($(e.target).val().trim().length>0) && ($(e.target).val().trim().length<3)) return;
                                _data.quotes.filterObj.search=$(e.target).val().trim();
                                _loadQuotesInfo(function(){displayQuotes("#admin-quotes-quotes");});
                            }
                        });

                        //wire up pagination
                        $(".js-pagination a").on("click", function(e){
                            e.preventDefault();
                            _data.quotes.filterObj.page = $(e.target).attr("data-page-number")? $(e.target).attr("data-page-number").split(" ")[1]:1;
                            _loadQuotesInfo(function(){displayQuotes("#admin-quotes-quotes");});
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

                            var _popupData= _formatPopupData(e, {
                            _title: "Quote Details",
                            _dataObj: _quote});

                            _popupData.properties = _quote.properties;
                            _popupData.distributorInfo =  EyeCueLab.JSON.getObjectsByPattern(

                                _quote, {
                                "containsIn(class)":["user"]
                            })[0];

                            _popupData.customerInfo = EyeCueLab.JSON.getObjectsByPattern(
                                _quote, {
                                "containsIn(class)":["customer"]
                            })[0];

                            _popupData.productInfo =  EyeCueLab.JSON.getObjectsByPattern(
                                _quote, {
                                "containsIn(class)":["product"]
                            })[0];

                            ["_path","id"].forEach(function(_hideKey){
                                delete _popupData.distributorInfo.properties[_hideKey];
                                delete _popupData.customerInfo.properties[_hideKey];
                                delete _popupData.productInfo.properties[_hideKey];
                            });

                            $("#js-screen_mask").fadeIn(100, function(){
                                EyeCueLab.UX.getTemplate("/templates/admin/quotes/popups/_quote_to_order_popup_container.handlebars.html",_popupData, $("#js-screen_mask"), function(){
                                    SunStand.Admin.displayPopup({_popupData:_popupData, _callback:function(){displayQuotes("#admin-quotes-quotes-init")}});
                                });
                            });
                        });
                    });
                 break;


                case "#admin-quotes-orders-init":
                    _loadOrdersInfo(function(){displayQuotes("#admin-quotes-orders");});
                break;

                case "#admin-quotes-orders":
                    $(".js-search_box").fadeIn();
                    $(".js-admin_dashboard_detail_container, .js-admin_dashboard_column.summary").css("opacity",0);
                    //position indicator
                    EyeCueLab.UX.getTemplate("/templates/admin/quotes/_nav.handlebars.html", {}, $(".js-admin_dashboard_column.detail .section_nav"), function(){
                        SunStand.Admin.positionIndicator($(".js-dashboard_section_indicator.second_level"), $(".js-admin_dashboard_column.detail nav.section_nav a[href=#admin-quotes-orders-init]"));
                        if((!!_data.orders.filterObj.search)) $(".js-search_box").val(_data.orders.filterObj.search);
                    });

                    EyeCueLab.UX.getTemplate("/templates/admin/quotes/orders/_summary.handlebars.html", {}, $(".js-admin_dashboard_column.summary"), function(){
                        if(!_data.orders.filterObj.page) _data.orders.filterObj.page = 1;
                        if(!_data.orders.filterObj.sort) _data.orders.filterObj.sort = "created";

                        $(".js-orders_sort_type option").each(function(){
                            if(this.value === _data.orders.filterObj.sort) $(".js-orders_sort_type").val(this.value);
                        });

                        $(".js-orders_sort_type").on("change", function(e){
                            _data.orders.filterObj.sort=$(e.target).val();
                            _loadOrdersInfo(function(){displayQuotes("#admin-quotes-orders")});
                        });
                    });

                    var _displayData=_data.orders;
                    _displayData.paginationInfo= _paginateData(_getObjectsByCriteria(_displayData, {name:"page"})[0], {prefix:"js-orders", actionableCount:10});

                    EyeCueLab.UX.getTemplate("/templates/admin/quotes/orders/_orders.handlebars.html", _displayData, $(".js-admin_dashboard_detail_container"), function(){
                        $(".js-admin_dashboard_detail_container, .js-admin_dashboard_column.summary").animate({"opacity":1});
                        $(".js-search_box").on("click", function(e){e.preventDefault();});
                        $(".js-search_box").on("keypress", function(e){
                            if(e.keyCode == 13){
                                if(($(e.target).val().trim().length>0) && ($(e.target).val().trim().length<3)) return;
                                _data.orders.filterObj.search=$(e.target).val().trim();
                                _loadOrdersInfo(function(){displayQuotes("#admin-quotes-orders")});
                            }
                        });

                        //pagination
                        $(".js-pagination a").on("click", function(e){
                            e.preventDefault();
                            _data.orders.filterObj.page= $(e.target).attr("data-page-number")? $(e.target).attr("data-page-number").split(" ")[1]:1;
                            _loadOrdersInfo(function(){displayQuotes("#admin-quotes-orders")});
                        });
                        //order details
                        //TODO:make this global
                        $(".js-order_details").on("click", function(e){
                            e.preventDefault();
                            var _url=$(this).attr("data-detail-href");
                            _showOrderDetails(_url);

                        });

                    });

                break;

                case "#admin-quotes-pay-periods-init":
                    _loadPayPeriodsInfo(function(){displayQuotes("#admin-quotes-pay-periods");});

                break;

                case "#admin-quotes-pay-periods":

                    $(".js-admin_dashboard_detail_container, .js-admin_dashboard_column.summary").css("opacity",0);
                    //position indicator
                    EyeCueLab.UX.getTemplate("/templates/admin/quotes/_nav.handlebars.html", {}, $(".js-admin_dashboard_column.detail .section_nav"), function(){
                        SunStand.Admin.positionIndicator($(".js-dashboard_section_indicator.second_level"), $(".js-admin_dashboard_column.detail nav.section_nav a[href=#admin-quotes-pay-periods-init]"));
                    });

                    EyeCueLab.UX.getTemplate("/templates/admin/quotes/pay_periods/_summary.handlebars.html", {}, $(".js-admin_dashboard_column.summary"), function(){
                    });

                    _displayData={};
                    $.extend(true, _displayData , _data.pay_periods);

                    _displayData.entities.forEach(function(entity){
                        var t = entity.properties.start_date;
                        entity.properties.startDisplayDate=new Date(parseInt(t.split("-")[0]),parseInt(t.split("-")[1])-1,parseInt(t.split("-")[2])).toDateString();
                        t = entity.properties.end_date;
                        entity.properties.endDisplayDate = new Date(parseInt(t.split("-")[0]),parseInt(t.split("-")[1])-1,parseInt(t.split("-")[2])).toDateString();
                    });

                    EyeCueLab.UX.getTemplate("/templates/admin/quotes/pay_periods/_pay_periods.handlebars.html", _displayData, $(".js-admin_dashboard_detail_container"), function(){
                        $(".js-admin_dashboard_detail_container, .js-admin_dashboard_column.summary").animate({"opacity":1});
                        $(".js-search_box").fadeOut(200);

                        //bonus_payments details
                        $(".js-bonus_payments_link").on("click", function(e){
                            e.preventDefault();
                            var _pay_period_id = $(e.target).parents("tr").attr("data-pay-period-id");
                            var _pay_period_obj = EyeCueLab.JSON.getObjectsByPattern(_data.pay_periods, {"containsIn(properties)":[_pay_period_id]})[0];
                            _ajax({
                                _ajaxType:"get",
                                _url:_getObjectsByCriteria(_pay_period_obj, {rel:"self"})[0].href,
                                _callback:function(data, text){
                                    var _bonus_payments_url = EyeCueLab.JSON.getObjectsByPattern(data.entities, {"containsIn(class)":["list", "bonus_payments"]})[0].href;
                                    EyeCueLab.JSON.asynchronousLoader([{url:_bonus_payments_url, data:{}}], function(_returnJSONs){
                                        var _bonus_payments_obj = EyeCueLab.JSON.getObjectsByPattern(_returnJSONs, {"containsIn(class)":["list", "bonus_payments"]})[0];
                                        var _popupData= _bonus_payments_obj;
                                        _popupData.properties.metrics =data.properties.totals;

                                        _popupData.title="Bonus Payments Detail <br>"+data.properties.title;
                                        _popupData.paginationInfo=_paginateData(_getObjectsByCriteria(_bonus_payments_obj, {name:"page"})[0], {prefix:"js-popup", actionableCount:10});
                                        _popupData.paginationInfo.templateName="/templates/admin/quotes/popups/_bonus_payments_listing.handlebars.html",
                                        _popupData.paginationInfo.templateContainer="#js-popup .js-popup_content_container";
                                        $("#js-screen_mask").fadeIn(100, function(){
                                            EyeCueLab.UX.getTemplate("/templates/admin/quotes/popups/_pay_periods_container.handlebars.html",_popupData, $("#js-screen_mask"), function(){
                                                $("#js-popup").css("opacity","0");
                                                EyeCueLab.UX.getTemplate("/templates/admin/quotes/popups/_bonus_payments_listing.handlebars.html",_popupData, $("#js-popup .js-popup_content_container"), function(){
                                                    SunStand.Admin.displayPopup({_popupData:_popupData, _css:{width:1000} });
                                                    console.log(_popupData);
                                                });
                                            });
                                        });
                                    });
                                }
                            });
                        });

                        //rank achievement details
                        $(".js-rank_achievements_link").on("click", function(e){
                            e.preventDefault();
                            var _pay_period_id = $(e.target).parents("tr").attr("data-pay-period-id");
                            var _pay_period_obj = EyeCueLab.JSON.getObjectsByPattern(_data.pay_periods, {"containsIn(properties)":[_pay_period_id]})[0];
                            _ajax({
                                _ajaxType:"get",
                                _url:_getObjectsByCriteria(_pay_period_obj, {rel:"self"})[0].href,
                                _callback:function(data, text){
                                    var _rank_achievements_url = EyeCueLab.JSON.getObjectsByPattern(data.entities, {"containsIn(class)":["list", "rank_achievements"]})[0].href;
                                    EyeCueLab.JSON.asynchronousLoader([{url:_rank_achievements_url,data:{}}], function(_returnJSONs){
                                        var _rank_achievements_obj = EyeCueLab.JSON.getObjectsByPattern(_returnJSONs, {"containsIn(class)":["list", "rank_achievements"]})[0];
                                        var _popupData= _rank_achievements_obj;
                                        _popupData.properties.metrics =data.properties.totals;
                                        _popupData.pay_period = _pay_period_obj.properties;
                                        _popupData.title="Rank Achievements Detail<br>"+data.properties.title;
                                        _popupData.paginationInfo=_paginateData(_getObjectsByCriteria(_rank_achievements_obj, {name:"page"})[0], {prefix:"js-popup", actionableCount:10});
                                        _popupData.paginationInfo.templateName="/templates/admin/quotes/popups/_rank_achievements_listing.handlebars.html",
                                        _popupData.paginationInfo.templateContainer="#js-popup .js-popup_content_container";

                                        $("#js-screen_mask").fadeIn(100, function(){
                                            EyeCueLab.UX.getTemplate("/templates/admin/quotes/popups/_pay_periods_container.handlebars.html",_popupData, $("#js-screen_mask"), function(){
                                                $("#js-popup").css("opacity","0");
                                                EyeCueLab.UX.getTemplate("/templates/admin/quotes/popups/_rank_achievements_listing.handlebars.html",_popupData, $("#js-popup .js-popup_content_container"), function(){
                                                    SunStand.Admin.displayPopup({_popupData:_popupData, _css:{width:1000} });
                                                    console.log(_popupData);
                                                });
                                            });
                                        });
                                    })
                                }
                            });
                        });

                        //calculated pay period, order totals detail
                        $(".js-order_totals_link").on("click", function(e){
                            e.preventDefault();
                            var _pay_period_id = $(e.target).parents("tr").attr("data-pay-period-id");
                            var _pay_period_obj = EyeCueLab.JSON.getObjectsByPattern(_data.pay_periods, {"containsIn(properties)":[_pay_period_id]})[0];
                            //gather info for the pay period
                            _ajax({
                                _ajaxType:"get",
                                _url:_getObjectsByCriteria(_pay_period_obj, {rel:"self"})[0].href,
                                _callback:function(data, text){
                                    var _order_total_url = EyeCueLab.JSON.getObjectsByPattern(data.entities, {"containsIn(class)":["list", "order_totals"]})[0].href
                                    EyeCueLab.JSON.asynchronousLoader([{url:_order_total_url, data:{}}], function(_returnJSONs){
                                        var _order_total_obj = EyeCueLab.JSON.getObjectsByPattern(_returnJSONs, {"containsIn(class)":["list", "order_totals"]})[0];
                                        var _popupData= _order_total_obj;
                                        _popupData.properties.metrics =data.properties.totals;
                                        _popupData.pay_period = _pay_period_obj.properties;
                                        _popupData.title="Order Totals Detail<br>"+data.properties.title;
                                        _popupData.paginationInfo=_paginateData(_getObjectsByCriteria(_order_total_obj, {name:"page"})[0], {prefix:"js-popup", actionableCount:10});
                                        _popupData.paginationInfo.templateName="/templates/admin/quotes/popups/_order_totals_listing.handlebars.html",
                                        _popupData.paginationInfo.templateContainer="#js-popup .js-popup_content_container";

                                        $("#js-screen_mask").fadeIn(100, function(){
                                            EyeCueLab.UX.getTemplate("/templates/admin/quotes/popups/_pay_periods_container.handlebars.html",_popupData, $("#js-screen_mask"), function(){
                                                $("#js-popup").css("opacity","0");
                                                EyeCueLab.UX.getTemplate("/templates/admin/quotes/popups/_order_totals_listing.handlebars.html",_popupData, $("#js-popup .js-popup_content_container"), function(){
                                                    SunStand.Admin.displayPopup({_popupData:_popupData, _css:{width:1000} });
                                                    console.log(_popupData)

                                                });
                                            });
                                        });
                                    });
                                }
                            }); //end of calculated pay period, order totals detail
                        });

                        //send users to the pay period detail page
                        $(".js-pay_period_detail").on("click", function(e){
                            e.preventDefault();
                            var _pay_period_id = $(e.target).parents("tr").attr("data-pay-period-id");
                            var _pay_period_obj = EyeCueLab.JSON.getObjectsByPattern(_data.pay_periods, {"containsIn(properties)":[_pay_period_id]})[0];
                            _showPayPeriodDetails({_pay_period_id:_pay_period_id, _pay_period_obj:_pay_period_obj});
                        });//end of pay period detail

                    });

                break;

            }
        }

        function _showPayPeriodDetails(_options){
            _ajax({
                _ajaxType:"get",
                _url:_getObjectsByCriteria(_options._pay_period_obj, {rel:"self"})[0].href,
                _callback:function(data, text){
                    _displayData=data;
                    console.log(data)
                    EyeCueLab.UX.getTemplate("/templates/admin/quotes/pay_periods/_pay_period_details.handlebars.html", _displayData, $(".js-admin_dashboard_detail_container"), function(){
                        $(".js-pay_period_listing").on("click", function(e){
                            e.preventDefault();
                            displayQuotes("#admin-quotes-pay-periods");
                        });
                        //calculation button
                        $(".js-calculate_pay_period").on("click", function(e){
                            e.preventDefault();
                            console.log("calculating "+_options._pay_period_id)
                            //var _pay_period_id= $(e.target).parents("tr").attr("data-pay-period-id");
                            _calculatePayPeriod(EyeCueLab.JSON.getObjectsByPattern(_data.pay_periods, {"containsIn(properties)":[_options._pay_period_id]})[0], function(){

                                _showPayPeriodDetails(_options)
                            });
                        });

                        //disbursement button
                        $(".js-disburse_pay_period").on("click", function(e){
                            e.preventDefault();
                            console.log("disbursing:..... "+_options._pay_period_id)
                            //var _pay_period_id= $(e.target).parents("tr").attr("data-pay-period-id");
                            _disbursePayPeriod(EyeCueLab.JSON.getObjectsByPattern(_data.pay_periods, {"containsIn(properties)":[_options._pay_period_id]})[0], function(){

                                _showPayPeriodDetails(_options)
                            });
                        });


                        //default to order total
                        if(typeof _options.category ==="undefined") {
                            _options.category={
                                "classType":"orders",
                                "templateName":"/templates/admin/quotes/popups/_orders_listing.handlebars.html"
                            };
                        }

                        $("#pay_period_detail_nav a."+_options.category.classType).addClass("js-active");

                        _ajax({
                            _ajaxType:"get",
                            _url:_getObjectsByCriteria(_options._pay_period_obj, {rel:"self"})[0].href,
                            _callback:function(data, text){
                                if(typeof data.entities === "undefined") return;
                                var _url = EyeCueLab.JSON.getObjectsByPattern(data.entities, {"containsIn(class)":["list", _options.category.classType]})[0].href;
                                EyeCueLab.JSON.asynchronousLoader([{url:_url, data:{}}], function(_returnJSONs){
                                    var _dataObj = EyeCueLab.JSON.getObjectsByPattern(_returnJSONs, {"containsIn(class)":["list", _options.category.classType]})[0];
                                    var _displayData= _dataObj;
                                    _displayData.properties.metrics =data.properties.totals;
                                    _displayData.pay_period = _options._pay_period_obj.properties;
                                    /*_displayData.title="Order Totals Detail<br>"+data.properties.title;
                                    _displayData.paginationInfo=_paginateData(_getObjectsByCriteria(_dataObj, {name:"page"})[0], {prefix:"js-popup", actionableCount:10});
                                    _displayData.paginationInfo.templateName="/templates/admin/quotes/popups/_order_totals_listing.handlebars.html",
                                    _displayData.paginationInfo.templateContainer="#js-popup .js-popup_content_container";
                                    */
                                    EyeCueLab.UX.getTemplate(_options.category.templateName,_displayData, $(".pay_period_detail_container"), function(){
                                        console.log(_displayData)
                                        //navigae between sub categories
                                        $("#pay_period_detail_nav a").on("click", function(e){
                                            e.preventDefault();
                                            _options.category.classType=$(this).attr("class").replace("js-active","").trim();
                                            switch(_options.category.classType){
                                                case "orders":
                                                    _options.category.templateName="/templates/admin/quotes/popups/_orders_listing.handlebars.html";
                                                break;

                                                case "order_totals":
                                                    _options.category.templateName="/templates/admin/quotes/popups/_order_totals_listing.handlebars.html";
                                                break;
                                                case "bonus_payments":
                                                    _options.category.templateName="/templates/admin/quotes/popups/_bonus_payments_listing.handlebars.html";
                                                break;

                                                case "rank_achievements":
                                                    _options.category.templateName="/templates/admin/quotes/popups/_rank_achievements_listing.handlebars.html";
                                                break;

                                            }
                                            _showPayPeriodDetails(_options);
                                        });

                                        //order detail popup
                                        $(".js-order_details").on("click", function(e){
                                            e.preventDefault();
                                            var _url=$(this).attr("data-detail-href");
                                            _showOrderDetails(_url);
                                        });
                                    });

                                    /*$("#js-screen_mask").fadeIn(100, function(){
                                        _getTemplate("/templates/admin/quotes/popups/_pay_periods_container.handlebars.html",_displayData, $("#js-screen_mask"), function(){
                                            $("#js-popup").css("opacity","0");
                                            _getTemplate("/templates/admin/quotes/popups/_order_totals_listing.handlebars.html",_displayData, $("#js-popup .js-popup_content_container"), function(){
                                                _displayPopup({_popupData:_displayData, _css:{width:1000} });
                                                console.log(_displayData)

                                            });
                                        });
                                    });*/
                                });
                            }
                        }); //end of calculated pay period, order totals detail
                    })

                }
            });

        }

        function _showOrderDetails(_url){
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

                    if(typeof _getObjectsByCriteria(data, {"rel":"user-ancestors"}) !=="undefined" ) _endpoints.push({
                            url:_getObjectsByCriteria(data, {"rel":"user-ancestors"})[0].href,
                            data:{}
                        });
                    EyeCueLab.JSON.asynchronousLoader(_endpoints, function(_returnJSONs){
                        _popupData.uplineInfo = EyeCueLab.JSON.getObjectsByPattern(_returnJSONs, {"containsIn(class)":["list","users"]})[0];
                        _popupData.bonusInfo = EyeCueLab.JSON.getObjectsByPattern(_returnJSONs, {"containsIn(class)":["list","bonus_payments"]})[0];
                        $("#js-screen_mask").fadeIn(100, function(){
                            EyeCueLab.UX.getTemplate("/templates/admin/users/sales/popups/_order_details.handlebars.html",_popupData, $("#js-screen_mask"), function(){
                                SunStand.Admin.displayPopup({_popupData:_popupData, _css:{width:800}});
                                console.log(_popupData);
                            });
                        });
                    })
                }
            });

        }

        function leavePageWarning(){
            return "It looks like you're still calculating..."
        }

        function _calculatePayPeriod(_pay_period, _callback){
            var _action=_getObjectsByCriteria(_pay_period, "val~calculate")[0];   
            $("#js-wait_screen_mask").fadeIn(100, function(){
                window.onbeforeunload = leavePageWarning
                EyeCueLab.UX.getTemplate("/templates/admin/quotes/popups/_processing_popup.handlebars.html",{title:"Please Wait", instructions:"The calculation may take a few moments to complete. Thank you!"}, $("#js-wait_screen_mask"), function(){
                    SunStand.Admin.displayPopup({_popupData:{}});
                    _ajax({
                        _ajaxType:_action.method,
                        _url:_action.href,
                        _callback:function(data, text){
                            window.onbeforeunload = null;
                            $("#js-wait_screen_mask").fadeOut(100);
                            $("body").css("overflow", "auto");
                            if(typeof _callback == "function") _callback();
                            else return data;
                        }
                    });
                });
            });
        }

        function _disbursePayPeriod(_pay_period, _callback){
            console.log("DISBURSE PAY PERIOD....")
            console.log(_pay_period)
            console.log(_callback)
            var _action=_getObjectsByCriteria(_pay_period, "val~disburse")[0];
            $("#js-screen_mask").fadeIn(100, function(){
                EyeCueLab.UX.getTemplate("/templates/admin/quotes/popups/_processing_popup.handlebars.html",{title:"Please Wait", instructions:"The calculation may take a few moments to complete. Thakn you!"}, $("#js-screen_mask"), function(){
                    SunStand.Admin.displayPopup({_popupData:{}});
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

        function _initFilterObj(_listObj, _filterObj){
            if(_getObjectsByCriteria(_listObj, {name:"index"})[0] &&
                _getObjectsByCriteria(_listObj, {name:"index"})[0].fields.length>0){
                _getObjectsByCriteria(_listObj, {name:"index"})[0].fields.forEach(function(field){
                    _filterObj[field.name]=undefined;
                });
            }
        }

        function _loadQuotesInfo(_callback){
            if(typeof _data.quotes === "undefined") _data.quotes={};
            if(typeof _data.quotes.filterObj !=="undefined") delete _data.quotes.filterObj._path;

            _ajax({
                _ajaxType:"get",
                _url:"/a/quotes",
                _postObj:_data.quotes.filterObj,
                _callback:function(data, text){
                    var _filterObj = _data.quotes.filterObj; 
                    _data.quotes = data;
                    _data.quotes.filterObj = _filterObj;

                    if(typeof _data.quotes.filterObj === "undefined") {
                        _data.quotes.filterObj={};
                        _initFilterObj(data, _data.quotes.filterObj);
                    }

                    _data.quotes.entities.forEach(function(_quote){
                        _d = new Date(_quote.properties.created_at);
                        _quote.properties.localDateString = _d.toLocaleDateString();
                        _quote.properties._dataStatusDisplay = _quote.properties.data_status.join(", ");
                    });
                    if(typeof _callback === "function") _callback();
                }
            });
        }


        function _loadOrdersInfo(_callback){
            if(typeof _data.orders === "undefined") _data.orders={};
            if(typeof _data.orders.filterObj !=="undefined") delete _data.orders.filterObj._path;
            console.log(_data.orders.filterObj)
            _ajax({
                _ajaxType:"get",
                _url:"/a/orders",
                _postObj:_data.orders.filterObj,
                _callback:function(data, text){
                    var _filterObj = _data.orders.filterObj;
                    _data.orders = data;
                    _data.orders.filterObj=_filterObj;

                    if(typeof _data.orders.filterObj === "undefined") {
                        _data.orders.filterObj={};
                        _initFilterObj(data, _data.orders.filterObj);
                    }

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


        //* end admin adshboard specific utility functions


    }//end AdminDashboard class

});