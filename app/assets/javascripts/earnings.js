_ajax({
  _ajaxType: "get",
  _url: "/",
  _callback: function(data, text) {

    var current_user = data.properties.id
    var startYear = new Date().getFullYear()
    var startMonth = new Date().getMonth() + 1
    var endYear = startYear
    var endMonth = startMonth
    var currentMonth = 0;
    var detailsPage = 1;

    //Fetches&Fills Header Summary
    _ajax({
      _ajaxType: "get",
      _url: "/u/earnings/summary?format=json&user_id="+current_user+"&start_year="+startYear+"&start_month="+startMonth+"&end_year="+endYear+"&end_month="+endMonth,
      _callback: function(data, text) {
        var total = 0
        $.each(data.entities, function(i, entity){
          total += entity.properties.total_earnings
        })
        if(total == 0) data.properties.active = false;
        EyeCueLab.UX.getTemplate("/templates/auth/earnings/_header.handlebars.html", data, $(".section_header_content"), function(html) {});
      }
    });

    $(document).ready(function(){

      $(document).on("click", function(e){
       
      })

      //Returns the number of months between two dates
      function checkRange(){
        $('.warning').empty()
        var range = endMonth - startMonth + ((endYear - startYear)*12);
        if(range < 0) $('.warning').html("Invalid Date Range")
        else return range + 1;
      }

      function getEarnings(){
        currentMonth = parseInt(startMonth - 1)
        currentYear = parseInt(startYear)
        var _endPoints =[];
        var range = checkRange()
        for(i=0;i<range;i++){
          if(currentMonth == 12){
            currentMonth = 0
            currentYear += 1
          }
          currentMonth += 1 
          _endPoints.push({
              url:"/u/earnings/summary?format=json&user_id="+current_user+"&start_year="+startYear+"&start_month="+currentMonth+"&end_year="+startYear+"&end_month="+currentMonth,
              // url:"/u/earnings/summary?format=json&user_id="+current_user+"&start_year="+2014+"&start_month="+10+"&end_year="+2014+"&end_month="+10,
              data:{},
              name:"Summary"
          });
        }
        EyeCueLab.JSON.asynchronousLoader(_endPoints, function(_returnJSONs){
          _summaryData = EyeCueLab.JSON.getObjectsByPattern(_returnJSONs, {"containsIn(class)":["list", "earnings"]})

          populateMissing(_summaryData)
          
          EyeCueLab.UX.getTemplate("/templates/auth/earnings/_summary.handlebars.html", _summaryData, $(".section_body"), function(html) {
            clickEvents();
          });
        });
      }

      function populateMissing(){
        currentMonth = startMonth - 1;
        currentYear = parseInt(startYear);

        for(var i = 0; i < _summaryData.length; i++){
          if(currentMonth == 12){
            currentMonth = 0;
            currentYear += 1;
          }
          if(_summaryData[i].entities.length === 0){
            _summaryData[i].properties.active = false;
            _summaryData[i].entities[0] = [] 
            _summaryData[i].entities[0].properties = {
                                                      "pay_period_year":(String(currentYear)),
                                                      "pay_period_month":(String(currentMonth)), 
                                                      "pay_period_type":"Monthly"
                                                     }
            for (var n = 1; n < 5; n++) {
               _summaryData[i].entities[n] = []
               _summaryData[i].entities[n].properties = {
                                                        "pay_period_type":"Weekly",
                                                        "amount":0,
                                                        "pay_period_week_number":(n),
                                                        "pay_period_date_range":"-"
                                                      }
            }
          } else {
            _summaryData[i].entities[0].properties.pay_period_month = String(currentMonth)
            _summaryData[i].entities[0].properties.pay_period_year = String(currentYear)
          }
          currentMonth += 1 
        }
      }

      function clickEvents(){ 
        $(".dropToggle.weekly").click(function(e){
          var selected = $(this)
          if(!selected.hasClass("active")) {
            e.stopPropagation() 
            selected.addClass("active")
            var row = selected.parent().parent()
            createRow(row)
           
            $('.dropDownDetails').velocity({height:"300px"}, function(){
              _ajax({
                _ajaxType: "get",
                _url:"/u/earnings/detail?format=json&user_id="+current_user+"&pay_period_id="+e.target.id,
                _callback: function(data, text) {
                  if(data.entities.length == 0){
                    data.properties.active = false;
                  }
                  EyeCueLab.UX.getTemplate("/templates/auth/earnings/_details.handlebars.html", data, $('#row'+row.index()+''), function(html) {
                    $('.slideData').fadeIn(300);
                  });
                }
              })
            });
          } else {
            selected.removeClass("active")
            reverseDrop(selected)
          }
        });    

        $(".dropToggle.monthly").click(function(e){
          var selected = $(this)
          if(!$(this).hasClass("active")) {
            e.stopPropagation() 
            selected.addClass("active")
            var pay_period_id = selected.attr("id")
            var row = selected.parent().parent()
            createRow(row)
            $('.dropDownDetails').velocity({height:"300px"}, function(){
              _ajax({
                _ajaxType: "get",
                _url:"/u/earnings/bonus?format=json&user_id="+current_user+"&pay_period_id="+pay_period_id,
                _callback: function(data, text) {
                
                  if(data.entities.length == 0){
                    data.properties.active = false;
                  }
                  EyeCueLab.UX.getTemplate("/templates/auth/earnings/_bonus.handlebars.html", data, $('#row'+row.index()+''), function(html) {
                    $('.slideData').fadeIn(300);
                    secondaryEvents(pay_period_id, row)
                  });
                }
              })
            });
          } else {
            selected.removeClass("active")
            reverseDrop(selected)
          }
        });    

        //For dropdowns within dropdowns
        function secondaryEvents(pay_period_id, row){
          $(".dropToggle.summary").click(function(e){
            e.preventDefault()
            e.stopPropagation() 
            var selected = $(this)
            var bonus_id = selected.children().attr("id")
            if(!selected.hasClass("active")) {
              selected.addClass("active")
              var row = selected.parent().parent()
              $("<tr class='temp-row'><td colspan='5' class='dropDownDetails' id='subrow"+row.index()+"'></td></tr>").insertAfter(row);
              $('.dropDownDetails').velocity({height:"300px"}, function(){
                _ajax({
                  _ajaxType: "get",
                  _url:"/u/earnings/bonus_detail?format=json&user_id="+current_user+"&pay_period_id="+pay_period_id+"&bonus_id="+bonus_id+"&page="+detailsPage,
                  _callback: function(data, text) {  
                    EyeCueLab.UX.getTemplate("/templates/auth/earnings/_summary_details.handlebars.html", data, $('#subrow'+row.index()+''), function(html) {
                    $('.slideData').fadeIn(400);
                    row = $('#subrow'+row.index()+'')
                    recursiveJquery(data, pay_period_id, bonus_id, row)
                  });
                  data.paginationInfo=_paginateData(_getObjectsByCriteria(data, {name:"page"})[0], {prefix:"js-popup", actionableCount:10});
                  data.paginationInfo.templateName="/templates/admin/quotes/popups/_order_totals_listing.handlebars.html",
                  data.paginationInfo.templateContainer="#js-popup .js-popup_content_container";
                  }
                })
              });
            } else {
              selected.removeClass("active")
              reverseDrop(selected)
            }
          });
        }
      }

      $('.dropdown').on("change",function(){
        startYear = $('#startYear option:selected').val()
        startMonth = $('#startMonth option:selected').val()
        endYear = $('#endYear option:selected').val()
        endMonth = $('#endMonth option:selected').val()
        if(startMonth < 10) startMonth = "0" + startMonth
        if(endMonth < 10) endMonth = "0" + endMonth
        getEarnings();
      })

      //Closes dropdown
      function reverseDrop(selected){
        selected = selected.parent().parent().next()
        selected.find('.dropDownDetails').css("padding","0px");
        selected.find('.slideData').remove()
        selected.find('.dropDownDetails').velocity({height:'0px'}, function(){
          selected.remove();
        });
      }

      function fillHeaders(){
        var months = [ "","January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December" ]
        $('.date').each(function(index, element){
        })
      }

      function createRow(row) {
        $("<tr class='temp-row'><td colspan='5' class='dropDownDetails' id='row"+row.index()+"'></td></tr>").insertAfter(row);
      }

      getEarnings();
    })

    //For paginated dropdowns
    function recursiveJquery(data, pay_period_id, bonus_id, row){
      
      $(".js-pagination a").on("click", function(e){
        var page = $(this).attr("data-page-number")
        e.stopPropagation();
        e.preventDefault();
        data.paginationInfo.page= $(e.target).attr("data-page-number")? $(e.target).attr("data-page-number").split(" ")[1]:1;
        _ajax({
          _ajaxType: "get",
          _url:"/u/earnings/bonus_detail?format=json&user_id="+current_user+"&pay_period_id="+pay_period_id+"&bonus_id="+bonus_id+"&page="+page,
          _callback: function(data, text) {
            data.paginationInfo=_paginateData(_getObjectsByCriteria(data, {name:"page"})[0], {prefix:"js-popup", actionableCount:10});
            data.paginationInfo.templateName="/templates/admin/quotes/popups/_order_totals_listing.handlebars.html",
            data.paginationInfo.templateContainer="#js-popup .js-popup_content_container";
            EyeCueLab.UX.getTemplate("/templates/auth/earnings/_paginated_details.handlebars.html", data, row.find('.paginated'), function(html) {
              if(detailsPage < page) {
                row.find('.paginated').velocity("transition.slideRightBigIn")
              } else {
                row.find('.paginated').velocity("transition.slideLeftBigIn")
              }
              detailsPage = page
              recursiveJquery(data, pay_period_id, bonus_id, row)
            });
         }
         });
      });
    }
  }
});
