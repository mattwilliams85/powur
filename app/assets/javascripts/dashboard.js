'use strict';

var _myID=0; //current user id
var _data={}; //main data object that contains user profile and genelogy info
var _animation_speed = 300;
var _dashboard; 
var kpiType = '';
var selectedUser = {}; //Tracks selected user during downline exploration

$(window).bind('page:change', function() {
  initPage();
});

// apply browser-specific rules
// this must be executed after each asynchronous request
// if it affects DOM elements

function initPage(){
  _data.root={};

  //get current user profile and initiate dashboard data
  _getRoot(function(){
    if ((_data.root.properties.first_name).length >= 11) {
      $('.js-user_first_name').text(_data.root.properties.first_name.substring(0,12) + '...');
    } else {
      $('.js-user_first_name').text(_data.root.properties.first_name );
    }
    _myID = _data.root.properties.id;
    _dashboard = new Dashboard();
    _dashboard.displayGoals();
    _dashboard.displayTeam();
    _dashboard.displayQuotes();
    _dashboard.displayKPIs();
    // if(_data.currentUser.avatar) $('#js-user_profile_image').attr('src', _data.currentUser.avatar.thumb);
    setInterval(_dashboard._countdown, 1000);
  });

  $('.js-user_first_name').on("click",function(){
     window.location.href = $(this).attr("href")
  })

  //wire up logout button
  $('#user_logout').on('click', function(e){
    _formSubmit(e, {}, '/login', 'delete', function(data, text){
    });
  });
}

//populate initial data on dashboard screen
function Dashboard(){
  _data.global = {};
  _data.global.thumbnail_size={'width':252,'height':197};
  _data.global.grid_width=32;
  _data.global.total_invitations=5;
  this.displayTeam = displayTeam;

  this.displayQuotes = displayQuotes;
  this.displayGoals = displayGoals;
  this.displayKPIs = displayKPIs;
  this._countdown = _countdown;

  //KPI Lables
  function displayKPIs(){
    var kpi={
      environment:{
        tab:{
          value:721.34,
          label:'CO2 Tons Saved'
        }
      },
      conversion:{
        tab:{
          value:78,
          label:'Orders'
        }
      },
      earnings:{
        tab:{
          value:'$2,182.67',
          label:'Total Earnings'
        }
      },
      genealogy:{
        tab:{
          value:327,
          label:'In Your Genealogy'
        }
      },
      hot_quotes:{
        tab:{
          value:11,
          label:"Current Rank"
        }
      },
    };

    Object.keys(kpi).forEach(function(key){
      $(".kpi_thumbnail[data-kpi-type="+key+"] .kpi_value span").html(kpi[key].tab.value)
      $(".kpi_thumbnail[data-kpi-type="+key+"] .kpi_label").html(kpi[key].tab.label)

    });

    //adjust font width for metrics
    $(".kpi_thumbnail h1").each(function(){
      var _width=$(this).find("span:first").width()+174;
      var _newWidth = Math.floor(220*60/_width);
      $(this).css("font-size", _newWidth+"pt");
    });

  }

  function displayGoals(path){
    return;
    // hook up the control for changing paths
    $("#pay_period_goal_path").on("change", function(e){
      $("#goal_meters .labels, #goal_meters .highlight").html("");
        displayGoals($(this).val());
    });

    var goals={};
    goals.sales={
      personal:{
        min:0,
        max:0,
        current:0,
      },
      group:{
        min:0,
        max:0,
        current:0
      }
    }
    //populate path dropdown
    if(typeof path === "undefined"){
      goals.paths=EyeCueLab.JSON.getObjectsByPattern(_data.currentUser.goals, {"containsIn(class)":["ranks", "list"]})[0].properties.paths;
      $("#pay_period_goal_path").html("");
      goals.paths.forEach(function(path){
        $("#pay_period_goal_path").append("<option value="+path+">Path: "+path+"</option>");
      });
    }


    goals.rank={
      pay_as_rank:_data.currentUser.goals.properties.pay_as_rank,
      next_rank:_data.currentUser.goals.properties.pay_as_rank+1
    }

    goals.next_rank=EyeCueLab.JSON.getObjectsByPattern(_data.currentUser.goals, {"containsIn(class)":["ranks", "list"]})[0].entities[goals.rank.next_rank-1];
    if(goals.rank.pay_as_rank>1){
      goals.current_rank=EyeCueLab.JSON.getObjectsByPattern(_data.currentUser.goals, {"containsIn(class)":["ranks", "list"]})[0].entities[goals.rank.pay_as_rank-1];
    }

    goals.next_rank.qualifications=_getObjectsByCriteria(goals.next_rank, {path:$("#pay_period_goal_path").val()});

    var displayPrimaryProduct={
      id:1, /* this is hardcoded for the sunrun solar item, this what will be displayed in the bars */
      name:"SunRun Solar Item"
    }


    //setup current personal and group sales total
    var sales = _getObjectsByCriteria(_data.currentUser.order_totals, {product:displayPrimaryProduct.name})[0];
    if(typeof sales !=="undefined"){
      goals.sales.personal.current=sales.personal;
      goals.sales.group.current=sales.group;
    }
    //setup the max
    goals.next_rank.qualifications.forEach(function(qualification){
      if(qualification.product_id==displayPrimaryProduct.id){
        $("#dashboard_personal_goals .product").html("Product: "+qualification.product);
        switch(qualification.type_display.toLowerCase()){
          case "personal sales":
            goals.sales.personal.max=qualification.quantity;
            $("#dashboard_personal_goals .personal_sales").html("Personal "+qualification.time_period+" sales");
            if(goals.sales.personal.current>goals.sales.personal.max) goals.sales.personal.current = goals.sales.personal.max
          break;

          case "group sales":
            goals.sales.group.max=qualification.quantity;
            $("#dashboard_personal_goals .group_sales").html("Group "+qualification.time_period+" sales");
            if(goals.sales.group.current>goals.sales.group.max) goals.sales.group.current = goals.sales.group.max
          break;
        }
      }
    });

    Object.keys(goals.sales).forEach(function(_key){
      var _section_width=$("#"+_key+"_sales .labels").width();
      var notches={};
      notches.total=goals.sales[_key].max-goals.sales[_key].min;
      notches.width=Math.ceil(_section_width/notches.total);
      notches.min=goals.sales[_key].min;
      notches.max=goals.sales[_key].max-1;
      notches.current = goals.sales[_key].current;
      for(var i=notches.min; i<=notches.max;i++){
        var _counter = (i<10)?"0"+i:i;
        var _maxCounter = (notches.max+1<10)?"0"+(notches.max+1):(notches.max+1);
        var _html=  "<div class='notch' style='width:"+((1/notches.total)*100)+"%;'>";
        _html+= "<span>"+_counter+"</span><div></div>";
        if(i<notches.max)_html+=  "</div>";
        else _html+= "<span class='last_notch'>"+_maxCounter+"</span><div class='last_notch'></div></div>"
        $("#"+_key+"_sales .labels").append(_html);
      }
      $("#"+_key+"_sales .highlight").animate({width:(((notches.current-notches.min)/notches.total*100)+"%")}, 1000)
    });
    $("#dashboard_personal_goals .next_rank").html("Next Rank: "+goals.rank.next_rank);

  }

  function displayTeam(_tab){
    if(_tab === undefined ) _tab="team.everyone";

    if(typeof _data.team_search === "undefined" )_data.team_search="";
    if(typeof _data.team_metric === "undefined" )_data.team_metric="quotes";
    if(typeof _data.team_period === "undefined" )_data.team_period="lifetime";

    _data.team=[]; // instantiate team/downlink genealogy object
    _data.team_count_per_page=4; // determine how many thumbnails to show per pagination
    _data._team=[];

    //wire up invitations listing hook
    $(".js-invites_thumbnail").on("click", function(e){
      e.preventDefault();
      $(this).closest('.team_info').css("border-bottom","0px")
      var _thisThumbnail = $(e.target).parents(".js-invites_thumbnail");
      if(_thisThumbnail.find("span.expand i").hasClass('fa-angle-up')){
        _thisThumbnail.closest('.team_info').css("border-bottom","1px solid #ccc")
      }
      _drillDown({"_type":"invitations",
            "_mainSectionID":$(e.target).parents("section").attr("id"),
            "_thumbnailIdentifier":".js-invites_thumbnail",
            "_target":$(e.target),
            "_arrowPosition":_thisThumbnail.find("span.expand i").offset().left});
    });

    _ajax({
      _ajaxType:"get",
      _url:"/u/users/",
      _postObj:{
        "performance[metric]":_data.team_metric,
        "performance[period]":_data.team_period,
        search:_data.team_search
      },
      _callback:function(data, text){
        console.log(data)
        if(data.entities.length<=0) return;
        var _containerObj = $("#dashboard_team .section_content.team_info .pagination_content");
        _data.team=data;
        _containerObj.siblings(".nav").css("display","none");
        _containerObj.css("left","0")
        _containerObj.css("width", (_data.global.thumbnail_size.width*data.entities.length)+"px");
        if(data.entities.length>=4) _containerObj.siblings(".nav").fadeIn();

        _containerObj.html("");
        _data.team.entities.forEach(function(member){
          _ajax({
            _ajaxType:"get",
            _url:"/u/users/"+member.properties.id+"/downline",
            _callback:function(data, text){
              member.properties.downline_count = data.entities.length;
              EyeCueLab.UX.getTemplate("/templates/_team_thumbnail.handlebars.html", member, undefined, function(html){
                _containerObj.append(html);
                // mattmark
              });

            }
          });
        });

        $("#team_search").unbind();
        $("#performance_metric").unbind();
        $("#performance_period").unbind();

        $("#team_search").on("keyup", function(e){
          switch(e.keyCode){
            case 13:
              if($(e.target).val().length<3 && $(e.target).val().length>0) return;
                if($(e.target).val().length>=3 || $(e.target).val().length==0){
                $("#dashboard_team > section").remove();
                  _data.team_search=$(e.target).val();
                _collapseTeam();
                displayTeam();
                }
            break;
          }
        });

        $("#performance_period, #performance_metric").on("change", function(e){
          e.preventDefault();
          _data[$(this).attr("name")]=$(this).val();
          $("#dashboard_team > section").remove();
          _collapseTeam();
          displayTeam();
        });
      }
    });
    _updateInvitationSummary();
  }

  //start quote dashboard info
  function displayQuotes(_tab){
    if(_tab === undefined ) _tab="quotes";

    _data.quotes =[];
    _data.quote_count_per_page=4;
    if(typeof _data.quote_sort === undefined )_data.quote_sort="created";
    if(typeof _data.quote_search === undefined )_data.quote_search="";
    _ajax({
      _ajaxType:"get",
      _url:"/u/quotes",
      _postObj:{
        search:_data.quote_search,
        sort:_data.quote_sort
      },
      _callback:function(data, type){
        _data.quotes=data;
        $(".js-new_quote_thumbnail").unbind();
        //wire up new leads hooks
        $(".js-new_quote_thumbnail").on("click", function(e){
          e.preventDefault();
          var _thisThumbnail = $(e.target).parents(".js-new_quote_thumbnail");
          var _thisAudience =  $(e.target).parents(".js-new_quote_thumbnail").attr("data-audience");
          _drillDown({"_type":"new_quote",
                "_mainSectionID":$(e.target).parents("section").attr("id"),
                "_thumbnailIdentifier":".js-new_quote_thumbnail",
                "_target":$(e.target),
                "_audience":_thisAudience,
                "_arrowPosition":_thisThumbnail.find("span.expand i").offset().left});
        });
        if(_data.quotes.entities.length<=0) return;
        var _containerObj = $("#dashboard_quotes .section_content.quotes_info .pagination_content");
        _containerObj.html("");
        if(_data.quotes.entities.length>4) _containerObj.siblings(".nav").fadeIn();
        _containerObj.css("width", (_data.global.thumbnail_size.width*_data.quotes.entities.length)+"px");
        var _displayData= data.entities;


        EyeCueLab.UX.getTemplate("/templates/_quote_thumbnail.handlebars.html", data.entities, _containerObj, function(){

          $("#quote_sort").unbind();
          $("#quote_search").unbind();
          $(".js-quote_thumbnail").unbind();

          //put in sort filter
          $("#quote_sort").on("change", function(e){
            _data.quote_sort=$(this).val();
            displayQuotes();
          });


          $("#quote_search").on("keyup", function(e){
            switch(e.keyCode){
              case 13:
                if($(e.target).val().length<3 && $(e.target).val().length>0) return;
                  if($(e.target).val().length>=3 || $(e.target).val().length==0){
                  $("#dashboard_quotes > section").remove();
                    _data.quote_search=$(e.target).val();
                  displayQuotes()
                  }
              break;
            }
          });

          //put in hooks for quotes thumbnail
          $(".js-quote_thumbnail").on("click", function(e){
            e.preventDefault();
            var _drillDownUserID=$(e.target).parents(".js-quote_thumbnail").attr("alt");
            var _thisThumbnail = $(e.target).parents(".js-quote_thumbnail");
            _drillDown({"_type":_tab,
                  "_mainSectionID":"dashboard_quotes",
                  "_thumbnailIdentifier":".js-quote_thumbnail",
                  "_target":$(e.target),
                  "_userID":_drillDownUserID,
                  "_arrowPosition":_thisThumbnail.find(".expand .fa").offset().left});
          });



        });

      }
    });

  }//end quote dashboard info

  //wire up impact metrics hooks
  (function(){
    _data.impact_metrics=[];
    _getData(_myID, "impact_metrics", _data.impact_metrics);

    //put in hooks for kpi thumbnails
    $(document).on("click",".kpi_thumbnail", function(e){
      e.preventDefault();
      var _thisThumbnail = $(e.target).parents(".kpi_thumbnail");
      var _thisKpiType = $(e.target).parents(".kpi_thumbnail").attr("data-kpi-type");

      _drillDown({"_type":"impact_metrics",
            "_mainSectionID":"dashboard_kpis",
            "_thumbnailIdentifier":".kpi_thumbnail",
            "_target":$(e.target),
            "_kpiType":_thisKpiType,
            "_arrowPosition":_thisThumbnail.find("span.expand i").offset().left});
    });
  })();
  //wire up the pagination hooks
  $(document).on("click", ".pagination_container .nav", function(e){
    e.preventDefault();
    var _pagination_content= $(this).siblings(".pagination_content");

    //animate the content
    var _pagination_width=_data.team_count_per_page*_data.global.thumbnail_size.width;

    //return if it's already being animated
    if( _pagination_content.filter(':animated').length>0) return;
    if($(this).attr("class").indexOf("left")>=0){
      if(_pagination_content.css("left")=="0px") return;
      _pagination_content.animate({"left":"+="+_pagination_width+"px"});
    }else{
      if((parseInt(_pagination_content.css("width"))+parseInt(_pagination_content.css("left"))-_pagination_width)<=0) return;
      _pagination_content.animate({"left":"-="+_pagination_width+"px"});
    }
  });

  //wire up the tab hooks
  $(document).on("click", ".tabs li a", function(e){
    e.preventDefault();
    if($(this).attr("class")===undefined) $(this).attr("class", "");
    if ($(this).attr("class").indexOf("active")>=0) return;

    _tabSelect({  "_type":$(this).attr("data-tab-type"),
        "_mainSectionID":$(this).parents("section").attr("id"),
        "_target":$(e.target),
    });
  });

  //main function that handles adding different types of drilldowns in different areas of the dashboard
  //the _options has options for the drilldown
  function _drillDown(_options){
    var _abortDrillDown =false;

    _collapseDrillDown(_options);
    if(_abortDrillDown) return;

    switch(_options._type){
      case "info":
       var _drillDownLevel=$("#dashboard_team .drilldown").length+1;
        //compile leader (hero) info
        $.getJSON("/u/users/"+_options._userID, function(){
          console.log("... loading user#"+_options._userID+" profile info");
        })
        .done(function(data){
          //prepare leader info
          var _userDetail={};
          _userDetail["name"] = data.properties.first_name+" "+data.properties.last_name;
          // _userDetail["profile_image"] = "/temp_dev_images/Tim.jpg";
          var gender = ["men","women"]
          _userDetail["profile_image"] = "http://api.randomuser.me/portraits/med/" + gender[Math.floor(Math.random()*2)] + "/" + Math.floor(Math.random() * 97) + ".jpg"
          // 
          _userDetail["email"] = data.properties.email;
          _userDetail["phone"] = data.properties.phone;
          _userDetail["generation"] = 1
          _userDetail["downline_url"]=_getObjectsByCriteria(data, {rel:"user-children"})[0].href;

          //add new team drilldown basic template layout with leader info
          var _html="<section class=\"drilldown level_"+_drillDownLevel+"\" data-drilldown-level=\""+_drillDownLevel+"\"></section>";
          $("#dashboard_team").append(_html);
          
          var _drilldownContainerObj = $('#dashboard_team [data-drilldown-level='+_drillDownLevel+']');

          _drilldownContainerObj.animate({height:"+=250px", opacity:1}, _animation_speed);
          _getTemplate("/templates/drilldowns/_team_details.handlebars.html",
            _userDetail,
            _drilldownContainerObj,
            function(){
              var _downlinkContainerObj = $('#dashboard_team [data-drilldown-level='+_drillDownLevel+'] .team_info .pagination_content');
              _downlinkContainerObj.css("width", (_data.global.thumbnail_size.width*5)+"px");
              EyeCueLab.UX.getTemplate("/templates/_info_thumbnail.handlebars.html", _userDetail, undefined, function(html){
                _downlinkContainerObj.html(html);
                _alternateColor(_drillDownLevel)
              });
          });
        });
      break;

      case "kpi":
       var _drillDownLevel=$("#dashboard_team .drilldown").length+1;
        //compile leader (hero) info
        $.getJSON("/u/users/"+_options._userID, function(){
          console.log("... loading user#"+_options._userID+" profile info");
        })
        .done(function(data){
         
          //prepare leader info
          var _userDetail={};
          _userDetail["name"] = data.properties.first_name+" "+data.properties.last_name;
          _userDetail["stats"] = "0";

          //add new team drilldown basic template layout with leader info
          var _html="<section class=\"drilldown level_"+_drillDownLevel+"\" data-drilldown-level=\""+_drillDownLevel+"\"></section>";
          $("#dashboard_team").append(_html);
          
          var _drilldownContainerObj = $('#dashboard_team [data-drilldown-level='+_drillDownLevel+']');

          _drilldownContainerObj.animate({height:"+=525px", opacity:1}, _animation_speed);
          _getTemplate("/templates/drilldowns/_team_details.handlebars.html",
            _userDetail,
            _drilldownContainerObj,
            function(){
              var _downlinkContainerObj = $('#dashboard_team [data-drilldown-level='+_drillDownLevel+'] .team_info .pagination_content');
              _downlinkContainerObj.css("width", (_data.global.thumbnail_size.width*5)+"px");
              EyeCueLab.UX.getTemplate("/templates/_kpi_conversion_thumbnail.handlebars.html", _userDetail, undefined, function(html){
                _downlinkContainerObj.html(html);
                _alternateColor(_drillDownLevel)
              });
          });
        });
        break;

      case "team.immediate":

        _ajax({
          _ajaxType:"get",
          _url:"/u/users/"+_data.currentUser.id,
          _callback:function(data,text){
            _data.currentUser.actions = data.actions
          }
        })

        var _thisThumbnail = $(_options._target)
        _thisThumbnail.closest('.team_info').find('.nav').hide();
        _ajax({
        _ajaxType:"get",
        _url:"/u/users/",
        _postObj:{
          search:_data.team_search
        },
        _callback:function(data, text){
          _data.team=data;
          _drillDownLevel = 1
          var _userDetail={};
          _userDetail["generation"] = 1
          var _html="<section class=\"drilldown level_"+_drillDownLevel+"\" data-drilldown-level=\""+_drillDownLevel+"\"></div></section>";
          $("#dashboard_team").append(_html);
          var _drilldownContainerObj = $('#dashboard_team [data-drilldown-level='+_drillDownLevel+']');
           _getTemplate("/templates/drilldowns/_team_details.handlebars.html", _userDetail, _drilldownContainerObj, function(){
          _drilldownContainerObj.animate({height:"+=250px", opacity:1}, _animation_speed);
          _data.team.entities.forEach(function(member){
            if(member.properties.id === parseInt(_options._userID)) return;
            var _downlinkContainerObj = $('#dashboard_team [data-drilldown-level='+_drillDownLevel+'] .team_info .pagination_content');
            if(data.entities.length>=5) _downlinkContainerObj.siblings(".nav").fadeIn();
            $(".team_info").css("border-bottom-width","1px");
            _downlinkContainerObj.css("width", (_data.global.thumbnail_size.width*4)+"px");
            _ajax({
              _ajaxType:"get",
              _url:"/u/users/"+member.properties.id+"/downline",
              _callback:function(data, text){
                member.properties.downline_count = data.entities.length;
                EyeCueLab.UX.getTemplate("/templates/_placement_thumbnail.handlebars.html", member, undefined, function(html){
                   _downlinkContainerObj.append(html);
                   _linkEvents();
                });
              }
            });
          });
        });
      } 
    })
    break;

    case "team.everyone":
    case "team":

      //determine the next drilldown level
      var _drillDownLevel=$("#dashboard_team .drilldown").length+1;
      //compile leader (hero) info
      $.getJSON("/u/users/"+_options._userID, function(){
        console.log("... loading user#"+_options._userID+" profile info");
      })
      .done(function(data){
        //prepare leader info
        var _userDetail={};
        _userDetail["name"] = data.properties.first_name+" "+data.properties.last_name;
        _userDetail["profile_image"] = "/temp_dev_images/Tim.jpg";
        _userDetail["email"] = data.properties.email;
        _userDetail["phone"] = data.properties.phone;
        _userDetail["generation"] = _drillDownLevel;
        _userDetail["downline_url"]=_getObjectsByCriteria(data, {rel:"user-children"})[0].href;
        _userDetail["generation"] = 1

        //add new team drilldown basic template layout with leader info
        var _html="<section class=\"drilldown level_"+_drillDownLevel+"\" data-drilldown-level=\""+_drillDownLevel+"\"></section>";
        $("#dashboard_team").append(_html);
        
        var _drilldownContainerObj = $('#dashboard_team [data-drilldown-level='+_drillDownLevel+']'); 
        // _drilldownContainerObj.scrollView(180);
        _drilldownContainerObj.animate({height:"+=250px", opacity:1}, _animation_speed);
        
        _getTemplate("/templates/drilldowns/_team_details.handlebars.html",
          _userDetail,
          _drilldownContainerObj,
          function(){
            _alternateColor(_drillDownLevel)
            
            //populate downlink thumbnails
            var _downlinkContainerObj = $('#dashboard_team [data-drilldown-level='+_drillDownLevel+'] .team_info .pagination_content'); 
            _ajax({
              _ajaxType:"get",
              _url:_userDetail.downline_url,
              _callback:function(data, text){
                _downlinkContainerObj.css("width", (_data.global.thumbnail_size.width*data.entities.length)+"px");
                if(data.entities.length>=4) _downlinkContainerObj.siblings(".nav").fadeIn();

                data.entities.forEach(function(member){
                  _ajax({
                    _ajaxType:"get",
                    _url:"/u/users/"+member.properties.id+"/downline",
                    _callback:function(data, text){
                      _downlinkContainerObj
                      member.properties.downline_count = data.entities.length;
                      EyeCueLab.UX.getTemplate("/templates/_team_thumbnail.handlebars.html", member, undefined, function(html){
                        //Makes previous tab match color of new drilldown
                        _downlinkContainerObj.append(html);
                      });
                    }
                  });
                });
              }
            });
          });
      })
      .fail(function(data){
        var _html="<section class=\"drilldown level_"+_drillDownLevel+"\" data-drilldown-level=\""+_drillDownLevel+"\"></section>";
        $("#dashboard_team").append(_html);
        var _drilldownContainerObj = $('#dashboard_team [data-drilldown-level='+_drillDownLevel+']');
        _drilldownContainerObj.css("opacity","0");
        // _drilldownContainerObj.scrollView(180);
        _drilldownContainerObj.animate({height:"+=300px", opacity:1}, _animation_speed);
        var _userDetail={};
        _getTemplate("/templates/drilldowns/_error_state.handlebars.html", {"audience":"promoter"}, _drilldownContainerObj);

      });
    break;


    case "quotes":
      if(_data.quotes.length==0) return;

      var _drillDownLevel=$("#dashboard_quotes .drilldown").length+1;
      var _html="<section class=\"drilldown level_"+_drillDownLevel+"\" data-drilldown-level=\""+_drillDownLevel+"\"></section>";
      $("#dashboard_quotes").append(_html);
      var _drilldownContainerObj = $('#dashboard_quotes [data-drilldown-level='+_drillDownLevel+']');

      //retrieve info from /customers/:id for the quote
      var _userDetail={};
      _ajax({
        _ajaxType:"get",
        _url:"/u/quotes/"+_options._userID,
        _callback:function(data, text){
          var _updateAction={};
          var _userDetail = data;

          _userDetail._allFields = _getObjectsByCriteria(data, "val=update")[0].fields;

          _userDetail._quoteFields = [];
          _userDetail._customerFields = [];


          ["roof_age", "roof_type", "credit_score_qualified", "square_feet", "average_bill", "utility"].forEach(function(field_name){
            _userDetail._quoteFields.push(_getObjectsByCriteria(_userDetail._allFields, "val="+field_name)[0])
          });

          ["first_name", "last_name", "email", "phone", "address", "city", "state", "zip"].forEach(function(field_name){
            _userDetail._customerFields.push(_getObjectsByCriteria(_userDetail._allFields, "val="+field_name)[0])
          });

          _userDetail._customerFields[6].fields = [
          'Alabama',
          'Alaska',
          'Arizona',
          'Arkansas',
          'California',
          'Colorado',
          'Connecticut',
          'Delaware',
          'District of Columbia',
          'Florida',
          'Georgia',
          'Hawaii',
          'Idaho',
          'Illinois',
          'Indiana',
          'Iowa',
          'Kansas',
          'Kentucky',
          'Louisiana',
          'Maine',
          'Maryland',
          'Massachusetts',
          'Michigan',
          'Minnesota',
          'Mississippi',
          'Missouri',
          'Montana',
          'Nebraska',
          'Nevada',
          'New Hampshire',
          'New Jersey',
          'New Mexico',
          'New York',
          'North Carolina',
          'North Dakota',
          'Ohio',
          'Oklahoma',
          'Oregon',
          'Pennsylvania',
          'Puerto Rico',
          'Rhode Island',
          'South Carolina',
          'South Dakota',
          'Tennessee',
          'Texas',
          'Utah',
          'Vermont',
          'Virginia',
          'Washington',
          'West Virginia',
          'Wisconsin',
          'Wyoming'
          ];

          $.extend(true, _updateAction, EyeCueLab.JSON.getObjectsByPattern(data, {"containsIn(fields)":{name:"zip"}})[0]);
          _updateAction.fields.forEach(function(field){
            _userDetail[field.name]=field.value;
          });
          //populate drilldown
          EyeCueLab.UX.getTemplate("/templates/drilldowns/_quotes_details.handlebars.html", _userDetail, _drilldownContainerObj, function(){

            //!!! applyBrowserSpecificRules() to solve compatibility issues for DOM elements on asynchronous requests (function exists in utility.js)
            applyBrowserSpecificRules();

            _drilldownContainerObj.find(".arrow").css("left",Math.floor(_options._arrowPosition-13));
            _drilldownContainerObj.find(".arrow").animate({top:"-=20px"}, 500);
            $("#customer_contact_form select[name='state'] option").filter(function(){return $(this).text()==_userDetail.state}).attr("selected", true);
            $("#customer_contact_form select[name='roof_material'] option").filter(function(){return $(this).text()==_userDetail.roof_material}).attr("selected", true);

            $(".js-remove_quote").unbind();
            $("#customer_contact_form .js-update_customer_info").unbind();
            $(".js-resend_quote_email").unbind();
            $(".js-close_drilldown").unbind();

            $(".js-remove_quote").on("click", function(e){
              e.preventDefault();
              _thisThumbnail.find(".expand").click();
              var _quoteID = $(e.target).parents(".drilldown_content").find("#customer_contact_form").attr("data-customer-id");
              _ajax({_ajaxType:"delete", _url:"/u/quotes/"+_quoteID, _callback:displayQuotes()});
            });

            $("#customer_contact_form .js-update_customer_info").on("click", function(e){
              e.preventDefault();
              var _quoteID = $(e.target).parents(".drilldown_content").find("#customer_contact_form").attr("data-customer-id");
              _ajax({_ajaxType:"patch", _url:"/u/quotes/"+_quoteID, _postObj:$("#customer_contact_form").serializeObject()});
              displayQuotes(); //this function can't happen as callback of _ajax() function because it will retrieve the old data
              _thisThumbnail.find(".expand").click();

            });

            $(".js-resend_quote_email").on("click", function(e){
              e.preventDefault();
              var _quoteID = $(e.target).parents(".drilldown_content").find("#customer_contact_form").attr("data-customer-id");
              _ajax({_ajaxType:"post", _url:"/u/quotes/"+_quoteID+"/resend", _postObj:{}, _callback:displayQuotes()});
              _thisThumbnail.find(".expand").click();

            });

            //wire up cancel button
            $(".js-close_drilldown").on("click", function(e){
              e.preventDefault();
              $(".js-thumbnail span.expand i").removeClass("fa-angle-up");
              $(".js-thumbnail span.expand i").addClass("fa-angle-down");
              _drilldownContainerObj.animate({height:"-=700px", opacity:0}, _animation_speed);
              $(".js-thumbnail").parent(".quote_thumbnail").animate({opacity:1}, _animation_speed);
            });

          });

        _drilldownContainerObj.css({"opacity":"0"});
        _drilldownContainerObj.animate({"height":"+=608px", "opacity": 1}, _animation_speed);
        
        }

      });

    break;

    case "new_quote":
      var _drillDownLevel=$("#"+_options._mainSectionID+" .drilldown").length+1;
      var _html="<section class=\"drilldown level_"+_drillDownLevel+"\" data-drilldown-level=\""+_drillDownLevel+"\"></section>";
      $("#"+_options._mainSectionID).append(_html);
      var _drilldownContainerObj = $("#"+_options._mainSectionID+" [data-drilldown-level="+_drillDownLevel+"]");

      var _fields={};
      _ajax({
        _ajaxType:"get",
        _url:"/u/quotes/",
        _callback:function(data, text){
          var _userDetail = data;

          _fields._allFields = _getObjectsByCriteria(data, "val=create")[0].fields;

          _fields._quoteFields = [];
          _fields._customerFields = [];

          ["roof_age", "roof_type", "credit_score_qualified", "square_feet", "average_bill", "utility"].forEach(function(field_name){
            _fields._quoteFields.push(_getObjectsByCriteria(_fields._allFields, "val="+field_name)[0])
          });

          ["first_name", "last_name", "email", "phone", "address", "city", "state", "zip"].forEach(function(field_name){
            _fields._customerFields.push(_getObjectsByCriteria(_fields._allFields, "val="+field_name)[0])
          });

          _fields._customerFields[6].fields = [
          'Alabama',
          'Alaska',
          'Arizona',
          'Arkansas',
          'California',
          'Colorado',
          'Connecticut',
          'Delaware',
          'District of Columbia',
          'Florida',
          'Georgia',
          'Hawaii',
          'Idaho',
          'Illinois',
          'Indiana',
          'Iowa',
          'Kansas',
          'Kentucky',
          'Louisiana',
          'Maine',
          'Maryland',
          'Massachusetts',
          'Michigan',
          'Minnesota',
          'Mississippi',
          'Missouri',
          'Montana',
          'Nebraska',
          'Nevada',
          'New Hampshire',
          'New Jersey',
          'New Mexico',
          'New York',
          'North Carolina',
          'North Dakota',
          'Ohio',
          'Oklahoma',
          'Oregon',
          'Pennsylvania',
          'Puerto Rico',
          'Rhode Island',
          'South Carolina',
          'South Dakota',
          'Tennessee',
          'Texas',
          'Utah',
          'Vermont',
          'Virginia',
          'Washington',
          'West Virginia',
          'Wisconsin',
          'Wyoming'
          ];

          //populate drilldown
          EyeCueLab.UX.getTemplate("/templates/drilldowns/_new_quote.handlebars.html", _fields, _drilldownContainerObj, function(){
             _drilldownContainerObj.find(".arrow").css("left",Math.floor(_options._arrowPosition-13));
             _drilldownContainerObj.find(".arrow").animate({top:"-=20px"}, 500);
            //wire up lead submission hook
            $("#new_lead_contact_form button").on("click", function(e){
              e.preventDefault();
              _formSubmit(e, $("#new_lead_contact_form"), "/u/quotes", "POST", function(data, text){
                $("#new_lead_contact_form").fadeOut(150, function(){
                  $("#new_lead_contact_form input").val("");
                  $("#new_lead_contact_form").fadeIn();
                  displayQuotes();
                  //close the drilldown after create
                  $(".js-new_quote_thumbnail span.expand i").removeClass("fa-angle-up");
                  $(".js-new_quote_thumbnail span.expand i").addClass("fa-angle-down");
                  _drilldownContainerObj.animate({height:"-=700px", opacity:0}, _animation_speed);
                });
              });
            });
            //wire up cancel button
            $(".js-close_drilldown").on("click", function(e){
              e.preventDefault();
              $(".js-new_quote_thumbnail span.expand i").removeClass("fa-angle-up");
              $(".js-new_quote_thumbnail span.expand i").addClass("fa-angle-down");
              _drilldownContainerObj.animate({height:"-=700px", opacity:0}, _animation_speed);
            });
          });

          _drilldownContainerObj.css({"opacity":"0"});
          _drilldownContainerObj.animate({"height":"+=608px", "opacity": 1}, _animation_speed);

        }

      });
    break;

    case "invitations":
      $('#dashboard_team .drilldown').remove();
      var _drillDownLevel=$("#"+_options._mainSectionID+" .drilldown").length+1;
      var _html="<section class=\"drilldown level_"+_drillDownLevel+"\" data-drilldown-level=\""+_drillDownLevel+"\"></section>";
      $("#"+_options._mainSectionID).append(_html);

      var _drilldownContainerObj = $("#"+_options._mainSectionID+" [data-drilldown-level="+_drillDownLevel+"]");
      _drilldownContainerObj.css("opacity","0");
      _drilldownContainerObj.animate({height:"+=240px", opacity:1}, _animation_speed);

      _data["invitations"]=[];
      //get listing array from json
      _getData(_myID, "invitations", _data["invitations"], function(){

        //pad the data object with blank invitations
        for(var i=_data["invitations"].length; i<5; i++) _data["invitations"].push({});

        //first place the listing template
        _getTemplate("/templates/drilldowns/new_invitations/_invitations_listing.handlebars.html", {}, _drilldownContainerObj, function(){
          _drilldownContainerObj.find(".arrow").css("left",Math.floor(_options._arrowPosition-13));
          _drilldownContainerObj.find(".arrow").animate({top:"-=20px"}, 500);

          //display thumbnails
          _getTemplate("/templates/drilldowns/new_invitations/_invitations_thumbnail.handlebars.html",  _data["invitations"], _drilldownContainerObj.find(".drilldown_content_section"), function(){

            //wire up expiration timer
            var _now = new Date();
            $(".js-expiration").each(function(){
              var _remainingSeconds, _remainingMinutes, _remainingHours;

              var _expiration = new Date($(this).attr("data-expiration-timestamp"));
              var _totalSeconds = Math.round((_expiration-_now)/1000);
              if(_totalSeconds >0){
                var _remainingHours = Math.floor(_totalSeconds/(60*60));
                var _totalSeconds = _totalSeconds - _remainingHours*(3600);
                var _remainingMinutes =  Math.floor(_totalSeconds/(60));
                var _remainingSeconds = _totalSeconds - _remainingMinutes*(60);
                if(_remainingSeconds<10) _remainingSeconds = "0"+_remainingSeconds;
                if(_remainingMinutes<10) _remainingMinutes = "0"+_remainingMinutes;
                if(_remainingHours<10) _remainingHours = "0"+_remainingHours;
                $(this).find(".js-expiration-hours").text(_remainingHours);
                $(this).find(".js-expiration-minutes").text(_remainingMinutes);
                $(this).find(".js-expiration-seconds").text(_remainingSeconds);
              }else{
                if($(this).closest(".js-new_invite_thumbnail").attr("class").indexOf("js-empty_seat")<0)
                  $(this).text("Expired");
              }
            });


            $(".js-new_invite_thumbnail").unbind();
            //wire up invitation detail hooks
            $(".js-new_invite_thumbnail").on("click", function(e){
              $('#dashboard_team .level_2').remove();
              e.preventDefault();
              // e.stopPropagation();
              _drillDown({"_type":"new_invitations",
                    "_mainSectionID":$(this).parents("section.dashboard_section").attr("id"),
                    "_thumbnailIdentifier":".js-new_invite_thumbnail",
                    "_target":$(e.target),
                    "_arrowPosition":$(this).find("span.expand i").offset().left});
            });

          });
        });

      });
    break;

    case "new_invitations":
      var _drillDownLevel=$("#"+_options._mainSectionID+" .drilldown").length+1;
      var _html="<section class=\"drilldown level_"+_drillDownLevel+"\" data-drilldown-level=\""+_drillDownLevel+"\"></section>";
      $("#"+_options._mainSectionID).append(_html);

      var _drilldownContainerObj = $("#"+_options._mainSectionID+" [data-drilldown-level="+_drillDownLevel+"]");
      _drilldownContainerObj.css("opacity","0");
      _drilldownContainerObj.animate({height:"+=400px", opacity:1}, _animation_speed);

      var _invitationDetail = {};
      var _thisThumbnail = $(_options._target)
      if(!_thisThumbnail.hasClass('new_thumbnail')) _thisThumbnail = $(_options._target).parents(_options._thumbnailIdentifier)
      _invitationDetail = _data["invitations"][_thisThumbnail.index()];
      _invitationDetail.invitationType="Existing";
      if(_thisThumbnail.attr("class").indexOf("js-empty_seat")>=0) _invitationDetail.invitationType="New";
      _getTemplate("/templates/drilldowns/new_invitations/_invitations_detail.handlebars.html", _invitationDetail, _drilldownContainerObj, function(){
        _drilldownContainerObj.find(".arrow").css("left",Math.floor(_options._arrowPosition-13));
        _drilldownContainerObj.find(".arrow").animate({top:"-=20px"}, 500);


        $("#new_promoter_invitation_form .button").unbind();
        $(".js-remove_advocate").unbind();
        $(".js-resend_invite_to_advocate").unbind();

        //change "Resend Invite" button text to "Update Invite" if the user changes the info on the form
        $(".js-invite").on("input", function(e){
          $(".js-resend_invite_to_advocate_text").text("Update Invite");
        })

        //wire up new invitation submission hook

        $("#new_promoter_invitation_form .button").on("click", function(e){
          e.preventDefault();
          var _thisForm = $(e.target).closest("#new_promoter_invitation_form");
          _formSubmit(e, $("#new_promoter_invitation_form"), "/u/invites", "POST", _displayUpdatedInvitation)
        });

        //wire up remove pending advocate capabilities
        $(".js-remove_advocate").on("click", function(e){
          e.preventDefault();
          var _id = $(e.target).closest(".drilldown_content_section").find(".invite_code").text();
          _ajax({_ajaxType:"delete", _url:"/u/invites/"+_id, _callback:_displayUpdatedInvitation()});
        });

        //wire up resend advocate invitation capaibiltiies
        $(".js-resend_invite_to_advocate").on("click", function(e){
          e.preventDefault();
          //if the information in the form has changed
          if (($("#js-invite_first_name").val !== _invitationDetail.first_name) ||
              ($("#js-invite_last_name").val !== _invitationDetail.last_name) ||
              ($("#js-invite_email").val !== _invitationDetail.email)) {
                //release the current invite code
                var _id =$(e.target).closest(".drilldown_content_section").find(".invite_code").text();
                _ajax({_ajaxType:"delete", _url:"/u/invites/"+_id});
                //create a new invite with the new form information
                var _thisForm = $(e.target).closest("#existing_promoter_invitation_form");
                _formSubmit(e, $("#existing_promoter_invitation_form"), "/u/invites", "POST", _displayUpdatedInvitation)
          } else {
            //otherwise, resend the invite
            var _id =$(e.target).closest(".drilldown_content_section").find(".invite_code").text();
            _ajax({_ajaxType:"post", _url:"/u/invites/"+_id+"/resend", _callback:_displayUpdatedInvitation()});
          }
        });



      });

    break;

    case "impact_metrics":
      var _drillDownLevel=$("#"+_options._mainSectionID+" .drilldown").length+1;
      var _html="<section class=\"drilldown level_"+_drillDownLevel+"\" data-drilldown-level=\""+_drillDownLevel+"\"></section>";
      $("#"+_options._mainSectionID).append(_html);
      var _drilldownContainerObj = $("#"+_options._mainSectionID+" [data-drilldown-level="+_drillDownLevel+"]");
      _drilldownContainerObj.css("opacity","0");
      _drilldownContainerObj.animate({height:"+=525px", opacity:1}, _animation_speed);
      var _templatePath;
      var _impactMetricsDetail = {};
      kpiType = _options._kpiType
      $(".arrow").hide()
      $(".js-thumbnail").find(".arrow").css("bottom","-20px")

      switch(kpiType){
        case "environment":
          _templatePath="/templates/drilldowns/impact_metrics/_kpi_environment_details.handlebars.html";
        break;
        case "conversion":
          _templatePath="/templates/drilldowns/impact_metrics/_kpi_conversion_details.handlebars.html";
        break;
        case "genealogy":
          _templatePath="/templates/drilldowns/impact_metrics/_kpi_genealogy_details.handlebars.html";
        break;
        case "earnings":
          _templatePath="/templates/drilldowns/impact_metrics/_kpi_total_earnings_details.handlebars.html";
        break;
        case "hot_quotes":
          _templatePath="/templates/drilldowns/impact_metrics/_kpi_hot_quotes_details.handlebars.html";
        break;
      }
      if(!_data.currentUser.avatar) _data.currentUser.avatar = { thumb: "http://www.insidersabroad.com/images/default_avatar_large.gif?1414172578" }
      _getTemplate(_templatePath, _data, _drilldownContainerObj, function(){
        $(".section_content").css("border-bottom-width","0px");
        $(".kpi_thumbnail[data-kpi-type=" + kpiType + "]").find(".arrow").show().animate({bottom:"+=20px"}, 500);
        if((kpiType !== "environment") && (kpiType !== "hot_quotes")) initKPI()
      });

    break;

    default:
      console.log("Drilldown type not found");
    break;
  }

  //JQUERY Events for placement
  function _linkEvents(){
    var action = _data.currentUser.actions[0]

    $(document).off('click','.advocate_avatar').on('click','.advocate_avatar', function() {
      var parentUserName = $(this).closest('.team_thumbnail').find('.name-span').text()
      var parentID = $(this).closest('.team_thumbnail').attr('alt')

      if(confirm("Click OK to place "+selectedUser.name+" on "+parentUserName+"'s team. You cannot undo this action.")) {
        _ajax({
          _ajaxType: action.method,
          _url: "/u/users/"+selectedUser.id+"/move?format=json&parent_id="+parentID,
        })
        displayTeam("team.everone")
        _collapseDrillDown(_options)
      }
    });

    //Animations
    $(".hover-team").on("mouseenter", function(e){
      $(this).find('.team_tab').velocity({translateY: "-35px"},{queue: false}, 200)
    })
    $(".hover-team").on("mouseleave", function(e){
      $(this).find('.team_tab').not('.active_tab').velocity({translateY: "0px"},{queue: false}, 200)
    })

    $(document).on("mouseenter", ".team_thumbnail", function(){
      if($(this).attr("alt") !== selectedUser.id){
        $(this).find('.advocate_avatar').css('cursor','pointer')
        $(this).find('.advocate_avatar').attr("src","/images/dashboard/plus.png")
      }
    })
    $(document).on("mouseleave", ".team_thumbnail", function(){
      if($(this).attr("alt") !== selectedUser.id){
        $(this).find('.advocate_avatar').attr("src","/temp_dev_images/Tim.jpg")
      }
    }) 
  }

  function _collapseDrillDown(_options){
       //set up context for what's being clicked
       var _currentLevelSectionObj=_options._target.closest("section");
       var _drillDownFocusLevel=_currentLevelSectionObj.attr("data-drilldown-level")*1;
       var _topLevelSectionObj = (_drillDownFocusLevel*1>0)? _topLevelSectionObj = _currentLevelSectionObj.parents("section"):_currentLevelSectionObj;
       var _thisThumbnail = _options._target.parents(_options._thumbnailIdentifier);//use class to identify (e.g. team_thumbnail, quote_thumbnail, etc.)
       var _drillDownDepth = _topLevelSectionObj.children("section").length;
       if(_thisThumbnail.length === 0) _thisThumbnail = _options._target

       //fade all other "unfocused" thumbnail out
       for(var i=0;i<_currentLevelSectionObj.find(_options._thumbnailIdentifier).length;i++){
         if(i!=_thisThumbnail.index(_options._thumbnailIdentifier)){
           var _neighborThumbnail = $(_currentLevelSectionObj.find(_options._thumbnailIdentifier+":eq("+i+")"));
           _neighborThumbnail.find('.js-thumbnail').animate({"opacity":".3"}, 300);
           _neighborThumbnail.find("span.expand i").removeClass("fa-angle-up");
           _neighborThumbnail.find("span.expand i").addClass("fa-angle-down");
         }
       }
       _thisThumbnail.find('.js-thumbnail').animate({opacity:'1'},300)
       _thisThumbnail.parents(_options._thumbnailIdentifier).find('.js-thumbnail').animate({opacity:'1'},300)

       //close any level after the current level
       for(var i=_drillDownDepth;i>_drillDownFocusLevel;i--){
           _topLevelSectionObj.find("[data-drilldown-level="+i+"]").remove();
       }

       //if checking on self collapse everything
       if(!_thisThumbnail.hasClass('team_thumbnail')){
        if(_thisThumbnail.find("span.expand i").attr("class").indexOf("fa-angle-up")>=0){
          $(".arrow").css("bottom","-20px").hide();
          $(".section_content").css("border-bottom-width","1px");
          _thisThumbnail.find("span.expand i").removeClass("fa-angle-up");
          _thisThumbnail.find("span.expand i").addClass("fa-angle-down");
          _abortDrillDown=true;

          _currentLevelSectionObj.find(_options._thumbnailIdentifier).animate({"opacity":1},_animation_speed);
          clearTimeout();
          return;
        }
       }
       
       _thisThumbnail.animate({"opacity":1}, 300);
       _thisThumbnail.find("span.expand i").removeClass("fa-angle-down");
       _thisThumbnail.find("span.expand i").addClass("fa-angle-up");
     }
   }

  function _tabSelect(_options){
    var _tabData;
    console.log(_options._mainSectionID);
    console.log(_options._type);
  }

  function _collapseTeam(){
    $("#dashboard_team .js-team_thumbnail").animate({"opacity":1});
    $("#dashboard_team .js-team_thumbnail").removeClass("fa-angle-up");
    $("#dashboard_team .js-team_thumbnail").removeClass("fa-angle-down");
    $("#dashboard_team .js-team_thumbnail").addClass("fa-angle-down");
  }

  //load the user dashboard basic info base on the current selected user id
  //_dataType dictates which endpoint to hit
  //optional: save info into a data variable if the variable is defined in param, otherwise display data object
  //optional: callback to allow additional operations (e.g. display) post loading
  function _getData(_userID, _dataType, _dataStore, _callback){
    var _endPoint="";
    switch(_dataType){
      case "team.everyone":
      case "team":
        _endPoint ="/u/users";
      break;

      case "quotes":
        _endPoint="/u/quotes";
      break;

      case "invitations":
        _endPoint="/u/invites";
      break;

      case "team":
        _endPoint ="/users";
      break;

      case "impact_metrics":
        return;
      break;

      default:
      break;


    }

    $.getJSON(_endPoint, function(){
      console.log("... loading user:"+_userID+" "+_dataType+" info");
    })
    .done(function(_d){
      if(typeof _dataStore !== "undefined"){
        if(Object.keys(_d).indexOf("entities")>=0){
          $.each(_d.entities, function(counter, val){ _dataStore.push(val.properties);});
        }else{
          //todo: fake data that needs to be replaced
          $.each(_d, function(counter, val){ _dataStore.push(val);});
        }
      }
      else
        console.log(_d);

      if(typeof _callback=="function") _callback();
    })
    .fail(function(){
      console.log("Unable to get user "+_dataType+" info")
    });
  }


  //_displayData function acts as middle layer btween JSON from database and the final template output
  //it prepares only necessary information and allows a place to add additional logic for template output
  //_dataType dictates what type of JSON is being processed
  //_dataObj is the actual JSON from the API endpoint
  //_containerObj is the DOM object that the final rendered template will be appending to
  function _displayData(_dataType, _dataObj, _containerObj, _callback){
    var _processedJSON=[];
    var _templatePath="";

    switch(_dataType){
      case "team.everyone":
      case "team":
        if (_dataObj.length==0) return;
        $.each(_dataObj, function(counter, val){
          _tempObj={};
          _tempObj["bindingObj"]=val.id+"_thumbnail";
          _tempObj["id"]=val.id;
          _tempObj["profile_image"]= (typeof val.profile_image === "undefined")? "/temp_dev_images/Tim.jpg" : val.profile_image;
          _tempObj["first_name"]= val.first_name;
          _tempObj["name"]= val.first_name+" "+val.last_name;
          _tempObj["phone"]= val.phone;
          _tempObj["email"]= val.email;
          _tempObj["rank"]="{no rank data}";
          /*for(key in val.rank[val.rank.length-1]) _tempObj["rank"] = key;
          _tempObj["quotes_approved"]= val.customers.quotes_approved.length;
          _tempObj["panels_installed"]= val.customers.panels_installed.length;
          _tempObj["team_size"]= val.genealogy.downlinks.length;*/
          _processedJSON.push(_tempObj);
        });
        _templatePath="/templates/_team_thumbnail.handlebars.html";
      break;

      case "quotes":
        if (_dataObj.length==0) return;
        $.each(_dataObj, function(counter, val){
          _tempObj={};
          _tempObj["bindingObj"]=val.id+"_thumbnail";
          _tempObj["id"]=val.id;
          _tempObj["first_name"]= val.first_name;
          _tempObj["last_name"]= val.last_name;
          _tempObj["name"]= val.full_name;
          _tempObj["status"]=val.status;

          for(var i=0;i<val.data_status.length;i++)
            _tempObj[val.data_status[i]]="complete";

          _processedJSON.push(_tempObj);
        });
        _templatePath="/templates/_quote_thumbnail.handlebars.html";
      break;

    }
    //naive determine pagination
    _containerObj.css("width", (_data.global.thumbnail_size.width*_processedJSON.length)+"px");

    //show pagination nav if thumbnail count is more than 4
    if(_processedJSON.length>=4) _containerObj.siblings(".nav").fadeIn();

    //populate the team section with appropriate _templatePath, data, and container
    _getTemplate(_templatePath, _processedJSON, _containerObj);

    if(_callback !== undefined) _callback();
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
            for(var i=0;i<_dataObj.length;i++)
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

  //start timeout function
  function _countdown(){
    var _remainingSeconds, _remainingMinutes, _remainingHours;
    $(".js-expiration-seconds").each(function(){
      _remainingSeconds = $(this).text()*1-1;
      if(_remainingSeconds<1){
        _remainingMinutes=$(this).siblings(".js-expiration-minutes").text()-1;
        if(_remainingMinutes<1){
          _remainingHours = $(this).siblings(".js-expiration-hours").text()-1;
          if(_remainingHours<1){
            $(this).html("Expired");
            return;
          }
          _remainingMinutes = 59;
          _remainingSeconds =60;
        }
        _remainingSeconds=60;
      }
      if(_remainingSeconds<10) _remainingSeconds = "0"+_remainingSeconds;
      if(_remainingMinutes<10) _remainingMinutes = "0"+_remainingMinutes;
      if(_remainingHours<10) _remainingHours = "0"+_remainingHours;
      $(this).text(_remainingSeconds);
      $(this).siblings(".js-expiration-minutes").text(_remainingMinutes);
      $(this).siblings(".js-expiration-hours").text(_remainingHours);
    });
  }

  function _updateInvitationSummary(_callback){
    //update invitation summary
    _data["invitations"]=[];
    _getData(_myID, "invitations", _data["invitations"], function(){
      var _availableInvitations = _data.global.total_invitations;
      for(var i=0;i<_data.invitations.length;i++) if(typeof _data.invitations[i].id !== "undefined") _availableInvitations--;
      $(".js-remaining_invitations").text(_availableInvitations);
      var _expiredInvitations=0;
      for(var i=0;i<_data.invitations.length;i++) {
        var _now = new Date();
        var _expiration = new Date( _data.invitations[i].expires);
        var _totalSeconds = Math.round((_expiration-_now)/1000);
        if(_totalSeconds <0) _expiredInvitations++;
      }
      $(".js-expired_invitations").text(_expiredInvitations+" Expired");
      if(typeof _callback === "function") _callback();
    });
  }

  //responsible to close the drilldowns and reset invitation listing
  function _displayUpdatedInvitation(){
    $(".js-remaining_invitations").click();
    _updateInvitationSummary(function(){
      $(".js-remaining_invitations").click();
    });
  }

  //team tab options 
  $(document).on("click", ".team_tab", function(e){
    var thisThumbnail = $(this).closest(".team_thumbnail")
    if($(this).hasClass('active_tab')){
      _closeTeamDrilldown($(this))
    } else {
      thisThumbnail.siblings().find('.active_tab').velocity({translateY:'0'},300).removeClass('active_tab')
      $(this).addClass('active_tab')
      switch($(this).attr('id')){
        case 'js-team_tab':
          _teamDrilldown('team.everyone', $(this))
          break;
        case 'js-impact_tab':
          _teamDrilldown('kpi', $(this))
          break;
        case 'js-info_tab':
          _teamDrilldown('info', $(this))
          break;
      }
    }
  });

  //kpi side-tab options
  $(document).on("click", ".js-kpi_tab", function(e){
    e.preventDefault();
    if(!$(this).hasClass('active')){
      $(this).addClass('active').siblings().removeClass('active')
    }
    switch($(this).attr('id')){
      case 'js-orders_tab':
        initUserKPI("orders", "line")
        break;
      case 'js-genealogy_tab':
        initUserKPI("genealogy", "bar")
        break;
      case 'js-earnings_tab':
        initUserKPI("earnings", "line")
        break;
      case 'js-ranking_tab':
    }
  });

  $(document).on("click", ".js-link_user", function(e){
    var thisLink = $(this)
    var thisThumbnail = $(this).closest('.js-team_thumbnail')
    var thumbnailArray = thisThumbnail.siblings('div')
    var i = 3
    selectedUser.id = thisThumbnail.attr("alt")
    selectedUser.name = thisThumbnail.find(".name-span").text();
    
    thisLink.toggleClass('active')

    if(thisLink.hasClass('active')) {
      _teamDrilldown('team.immediate' , thisLink)
      thisThumbnail.css('border-left','1px solid #eee')
      .find('.advocate_avatar').attr("src","/images/dashboard/Untitled-2.png");

      //animates each neighbor
      var a = setInterval(function(){
        $(thumbnailArray[i]).velocity({translateX: '1000px'},400)
        i -= 1
        if(i < 0) clearInterval(a)
      },100)
    } else {
      thisThumbnail.find('.advocate_avatar').attr("src","/temp_dev_images/Tim.jpg")
      thisThumbnail.find('.nav').show();
      _closeLinkDrilldown(thisLink, thumbnailArray, i);
      _closeTeamDrilldown(thisLink)
      
      //animation
      var a = setInterval(function(){
        $(thumbnailArray[i]).velocity({translateX: '0'},400).find('.js-thumbnail').animate({"opacity":"1"}, 300);
        i -= 1
        if(i < 0) {
          clearInterval(a)
          thisLink.parent().css('border-left-width','0px')
        }
      },100)
    }
  });

  function _closeLinkDrilldown(thisLink, thumbnailArray, i){
    $(document).off("mouseenter", ".team_thumbnail")
               .off("mouseleave", ".team_thumbnail")
    thumbnailArray.find('.advocate_avatar').attr("src","/temp_dev_images/Tim.jpg")
    thumbnailArray.css('border-left-width','0px')
    thisLink.removeClass('active')
    _closeTeamDrilldown(thisLink)
    thisLink.closest('.team_info').find('.nav').show();
    //animation
    var a = setInterval(function(){
      $(thumbnailArray[i]).velocity({translateX: '0'},400).find('.js-thumbnail').animate({"opacity":"1"}, 300).css('opacity','1');
      i -= 1
      if(i < 0) clearInterval(a)
    },100)
  }

  function _teamDrilldown(_type, target){
    target.addClass('active_tab')
    target.siblings().removeClass('active_tab')
    target.parents().eq(4).css("border-bottom","0px")
    target.closest('.team_info').css("border-bottom","0px")
    var _drillDownUserID=target.parents(".js-team_thumbnail").attr("alt");
    var _thisThumbnail = target.parents(".js-team_thumbnail");
    _drillDown({"_type": _type,
      "_mainSectionID":"dashboard_team",
      "_thumbnailIdentifier":".js-team_thumbnail",
      "_target":target,
      "_userID":_drillDownUserID});
  }

  function _closeTeamDrilldown(selected){
    selected.removeClass('active_tab')
    selected.closest('.js-team_thumbnail').siblings('div').find('.js-thumbnail').animate({opacity:'1'},300)
    var _thisLevel = parseInt(selected.closest('section').attr('data-drilldown-level'))
    var _lastLevel = parseInt($('.drilldown').last().attr('data-drilldown-level'))
    if(_thisLevel == 0) selected.closest('.team_info').css('border','1px solid #E5E5E5')
    
    for(var i=_thisLevel;i < _lastLevel;i++){
      $('.drilldown.level_'+(i+1)).hide()
    }
  }

  function _moveUser(event){
  
  }

  function _alternateColor(_drillDownLevel){
    if(_drillDownLevel % 2 === 0){
       $('.drilldown.level_'+_drillDownLevel).find('.drilldown_content').css('background-color',"#333") 
       $('.drilldown.level_'+(_drillDownLevel - 1)).find('.active_tab').css('background-color',"#333") 
       $('.drilldown.level_'+_drillDownLevel).find('.active_tab').css('background-color',"#444") 
    } else {
       $('.drilldown.level_'+_drillDownLevel).find('.drilldown_content').css('background-color',"#444")
       $('.drilldown.level_'+_drillDownLevel).find('.active_tab').css('background-color',"#333")
       $('.drilldown.level_'+(_drillDownLevel - 1)).find('.active_tab').css('background-color',"#444")   
    }
  }

  DashboardTopper.readyGO();

}// end Dashboard class



// Faux form editing animations

$(document).on("focus", "input", function(e){
   var elem = $(this);

   // Save current value of element
   elem.data('oldVal', elem.val());

   // Look for changes in the value
   elem.bind("propertychange keyup input paste", function(event){
      // If value has changed...
      if (elem.data('oldVal') != elem.val()) {
       // Updated stored value
       elem.data('oldVal', elem.val());

    $(this).parents(".form_row").siblings(".form_edit_actions").fadeIn(100);

     }
   });
 });


$(document).ready(function(){
  applyBrowserSpecificRules(); // to solve browser-specific DOM render issues (function exists in utility.js)
});
