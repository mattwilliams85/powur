// Colors

	var _brand = "32,194,241"
	var _sunnyside = "249,166,0"
	var _disabled = "226,234,233"


// Wrap thumbnail objects in a container per row
	

		// function wrapThumbsInRows() {


		// 	var winWidth = $(window).width();

		// 	var thumbWidth = 256;
		// 	var thumbsPerRow = Math.floor(winWidth / thumbWidth);

		// 	$(".section_content").each(function(){

		// 		var foobar = $(this);

		// 		var thumb = $(foobar).find(".js-thumbnail_parent");
		// 		var thumbs = thumb.length;

	 //  			if (thumb.parent().is(".thumb_row")) {
		// 		    thumb.unwrap();
		// 		}

		// 		for(var i = 0; i < thumb.length; i+=thumbsPerRow) {
		// 		  thumb.slice(i, i+thumbsPerRow).wrapAll("<div class='thumb_row row-" + Math.floor(i/thumbsPerRow + 1) + "' />");
		// 		}

		// 		$(".thumb_row").css("width", (thumbWidth * thumbsPerRow) + "px");

		// 	});

		// }

		//  $(document).ready(wrapThumbsInRows);

		//  // This doesn't work for some reason

		//  $(window).resize(wrapThumbsInRows);


	
// Show expanded details for dashboard objects


	function detailExpander(showID, btn_text){

		var thumbnail = $("#" + showID + "_thumbnail");
		var detail = $("#" + showID + "_detail");
		var jsDetail = $(".js-" + showID + "_detail");


		if($(detail).is(":visible")) {
			$(jsDetail).removeClass("active").html(btn_text);
			$(detail).hide();
			$(detail).parent().css("marginBottom","0");
		} else {
			$(detail).find("form").show();
			$(detail).find(".success").hide();
			$(".object_detail").hide().parent().css("marginBottom","0");

			$(detail).show();

			var detailHeight = $(detail).height();

			$(jsDetail).addClass("active").html("Close");
			$(detail).parent().css("marginBottom",(detailHeight + 16) + "px");

		}
		
		//detailExpander.stopPropagation();

	}

	// Form success for object detail view

	function detailConfirm(e) {
		$(e).parent("form").hide();
		$(e).parent("form").siblings(".success").show();
	}

	// Fake post invite advocate to show pending team object

	function postInvite() {
		var advocate_name = document.getElementById('advocate_name').value;

		$("#dashboard_team").find(".blank_state").hide();
		$("#dashboard_team").find(".invitee_name").html(advocate_name);
		$("#dashboard_team").find(".pending").fadeIn('fast');

	}


    function showSignupForm() {
    	go = event.target
    	$(go).parents(".banner_content").animate({ opacity: 0, right: "100%" }, 'slow', 'swing');
    	$(".js-signup_form").animate({ opacity: 1, bottom: "25%"}, 'slow', 'swing');

    }


    function showRequestForm() {
    	go = event.target
    	$(go).parents(".banner_content").animate({ opacity: 0, right: "100%" }, 'slow', 'swing');
    	$(".js-request_form").animate({ opacity: 1, bottom: "45%"}, 'slow', 'swing');

    }


	// // KP's easier version of DRMagicLabelWizzler
	//     	$("label").not(".checkbox label").hide().css("right", "-100px");
	//     	$("input").bind('click focus touch oninput', function() {
	//     		$(this).removeClass("is_valid is_not_valid");
	//       		$(this).prev("label").not(".checkbox").fadeIn("fast").css("right", "16px");

	// 			$(this).keyup(function() {
	// 				if ($(this).val().length > 10) {
	// 	          		$(this).prev("label:visible").fadeOut("fast");
	//         		} else {
	//           			$(this).prev("label").fadeIn("fast");
	//         		};
 //        		});
	// 		});

	// 		$("input.validate").blur(function() {
	//       		$(this).prev("label").not(".checkbox").fadeOut("fast");

	//       		// this is just to fake validation
	// 			if ($(this).val().length > 2) {
	// 	    		$(this).addClass("is_valid");
	// 	    	} else {
	// 	    		$(this).addClass("is_not_valid");		    		
	// 			};

	//     	});


$(document).ready(function() { // bind to document.ready instead of window.load because of Turbolinks



		// // KP's easier version of DRMagicLabelWizzler
	 //    	$("label").not(".checkbox label").hide().css("right", "-100px");
	 //    	$("input").bind('click focus touch oninput', function() {
	 //    		$(this).removeClass("is_valid is_not_valid");
	 //      		$(this).prev("label").not(".checkbox").fadeIn("fast").css("right", "16px");

		// 		$(this).keyup(function() {
		// 			if ($(this).val().length > 10) {
		//           		$(this).prev("label:visible").fadeOut("fast");
	 //        		} else {
	 //          			$(this).prev("label").fadeIn("fast");
	 //        		};
  //       		});
		// 	});

		// 	$("input.validate").blur(function() {
	 //      		$(this).prev("label").not(".checkbox").fadeOut("fast");

	 //      		// this is just to fake validation
		// 		if ($(this).val().length > 2) {
		//     		$(this).addClass("is_valid");
		//     	} else {
		//     		$(this).addClass("is_not_valid");		    		
		// 		};

	 //    	});

		
	// System feedback demo for settings page

		// $(".show_system_feedback").click(function() {
		// 	$("#system_feedback").removeClass("hide");
		
		// 	// Fadeout element after delay - ie, system feedback notice
		// 	$(".js-auto_fade_away").delay("2000").fadeTo("slow", 0.01, function(){ //fade
		// 	    $(this).slideUp("slow", function() { //slide up
		// 	    	$(this).remove(); //then remove from the DOM
		// 	    });
		// 	});
		// });

	// Notification expand demo for dashboard

		// $(".js-expand_notification").click(function() {
		// 	$(".js-expand_notification").animate({
		// 		height: "200px"
		// 	}, 250, function() {
		// 	    // Animation complete.
		// 	  });
		// });

		// $(".dismiss").click(function(){
		// 	$(this).parent().hide();
		// });


    // Signup form animations




    // Just to make sure my syntax is still valid - that's how good I am at this...
	// alert( "welcome" );


	// Charts

		// KPI Charts

			// Sales Chart

				var kpiChartSales = $("#kpi_chart_sales").get(0).getContext("2d");
				var myNewChart = new Chart(kpiChartSales);

				var kpiChartSalesData = [
					{
						value: 84,
						color:"rgba(" + _brand + ", 1)"
					},
					{
						value : 98,
						color : "rgba(" + _disabled + ", 1)"
					}

				]

				new Chart(kpiChartSales).Pie(kpiChartSalesData);

			// Team Chart

				var kpiChartTeam = $("#kpi_chart_team").get(0).getContext("2d");
				var myNewChart = new Chart(kpiChartTeam);

				var kpiChartTeamData = {
					labels : ["4/21", "4/28", "5/5", "5/12"],
					datasets : [
						{
							fillColor : "rgba(" + _brand + ", 1)",
							strokeColor : "rgba(" + _brand + ", 1)",
							pointColor : "rgba(" + _brand + ", 1)",
							pointStrokeColor : "#fff",
							data : [5, 6, 8, 13]
						},

						{
							fillColor : "rgba(" + _sunnyside + ", 1)",
							strokeColor : "rgba(" + _sunnyside + ", 1)",
							pointColor : "rgba(" + _sunnyside + ", 1)",
							pointStrokeColor : "#fff",
							data : [3, 8, 16, 22]
						}
					]
				}

				new Chart(kpiChartTeam).Bar(kpiChartTeamData, {scaleShowLabels: false});


			// Earnings Chart

				var kpiChartEarnings = $("#kpi_chart_earnings").get(0).getContext("2d");
				var myNewChart = new Chart(kpiChartEarnings);

				var kpiChartEarningsData = {
					labels : ["4/21", "4/28", "5/5", "5/12"],
					datasets : [
						{
							fillColor : "rgba(" + _brand + ", 1)",
							strokeColor : "rgba(" + _brand + ", 1)",
							pointColor : "rgba(" + _brand + ", 1)",
							pointStrokeColor : "#fff",
							data : [26, 42, 37, 35, 0]
						},
					]
				}

				new Chart(kpiChartEarnings).Line(kpiChartEarningsData, {scaleShowLabels: false});


			// Level Up Chart

				var kpiChartLevelUp = $("#kpi_chart_level_up").get(0).getContext("2d");
				var myNewChart = new Chart(kpiChartLevelUp);

				var kpiChartLevelUpData = [
					{
						value: 90,
						color:"rgba(" + _brand + ", 1)"
					},
					{
						value : 20,
						color : "rgba(" + _disabled + ", 1)"
					}

				]

				new Chart(kpiChartLevelUp).Doughnut(kpiChartLevelUpData);



			// My Sales Detail Chart

			var detailMySales = $("#detail_my_sales").get(0).getContext("2d");
				var myNewChart = new Chart(detailMySales);

				var detailMySalesData = {
					labels : ["1/6", "1/13", "1/20", "1/27", "2/3", "2/10", "2/17", "2/24", "3/3", "3/10", "3/17", "3/24", "3/31", "3/7", "4/14", "4/21", "4/28", "5/5", "5/12"],

					datasets : [
						{
							fillColor : "rgba(" + _brand + ", 1)",
							strokeColor : "rgba(" + _brand + ", 1)",
							pointColor : "rgba(" + _brand + ", 1)",
							pointStrokeColor : "#fff",
							data : [0,1,1,2,0,3,2,0,2,1,5,4,0,1,4,7,5,1,6]

						},

						{
							fillColor : "rgba(" + _brand + ", .5)",
							strokeColor : "rgba(" + _brand + ", .5)",
							pointColor : "rgba(" + _brand + ", .5)",
							pointStrokeColor : "#fff",
							data : [0,0,0,0,2,3,4,8,7,1,2,0,3,2,1,5,1,0,2]
						}
					]
				}

				new Chart(detailMySales).Bar(detailMySalesData, {
					scaleGridLineColor : "rgba(" + _disabled + ", 1)",
					scaleLineColor : "rgba(" + _disabled + ", 1)",
					scaleFontColor : "rgba(" + _disabled + ", 1)"
				});


			// Team Sales Detail Chart

			var detailTeamSales = $("#detail_team_sales").get(0).getContext("2d");
				var myNewChart = new Chart(detailTeamSales);

				var detailTeamSalesData = {
					labels : ["1/6", "1/13", "1/20", "1/27", "2/3", "2/10", "2/17", "2/24", "3/3", "3/10", "3/17", "3/24", "3/31", "3/7", "4/14", "4/21", "4/28", "5/5", "5/12"],

					datasets : [
						{
							fillColor : "rgba(" + _sunnyside + ", 1)",
							strokeColor : "rgba(" + _sunnyside + ", 1)",
							pointColor : "rgba(" + _sunnyside + ", 1)",
							pointStrokeColor : "#fff",
							data : [0,0,0,2,0,3,2,1,5,1,0,2,0,2,3,4,8,7,1]
						},

						{
							fillColor : "rgba(" + _sunnyside + ", .5)",
							strokeColor : "rgba(" + _sunnyside + ", .5)",
							pointColor : "rgba(" + _sunnyside + ", .5)",
							pointStrokeColor : "#fff",
							data : [0,1,1,5,4,0,1,4,7,5,1,6,2,0,3,2,0,2,1]

						}
					]
				}

				new Chart(detailTeamSales).Bar(detailTeamSalesData, {
					scaleGridLineColor : "rgba(" + _disabled + ", 1)",
					scaleLineColor : "rgba(" + _disabled + ", 1)",
					scaleFontColor : "rgba(" + _disabled + ", 1)"
				});


			// My Conversion Chart

				var detailMyConversions = $("#detail_my_conversions").get(0).getContext("2d");
				var myNewChart = new Chart(detailMyConversions);

				var detailMyConversionsData = [
					{
						value: 84,
						color:"rgba(" + _brand + ", 1)"
					},
					{
						value : 98,
						color : "rgba(" + _disabled + ", 1)"
					}

				]

				new Chart(detailMyConversions).Pie(detailMyConversionsData);


			// Team Conversion Chart

				var detailTeamConversions = $("#detail_team_conversions").get(0).getContext("2d");
				var myNewChart = new Chart(detailTeamConversions);

				var detailTeamConversionsData = [
					{
						value: 61,
						color:"rgba(" + _sunnyside + ", 1)"
					},
					{
						value : 98,
						color : "rgba(" + _disabled + ", 1)"
					}

				]

				new Chart(detailTeamConversions).Pie(detailTeamConversionsData);

});



