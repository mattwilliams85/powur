// Wrap thumbnail objects in a container per row
	

		function wrapThumbsInRows() {


			var winWidth = $(window).width();

			var thumbWidth = 256;
			var thumbsPerRow = Math.floor(winWidth / thumbWidth);

			$(".section_content").each(function(){

				var foobar = $(this);

				var thumb = $(foobar).find(".js-thumbnail_parent");
				var thumbs = thumb.length;

	  			if (thumb.parent().is(".thumb_row")) {
				    thumb.unwrap();
				}

				for(var i = 0; i < thumb.length; i+=thumbsPerRow) {
				  thumb.slice(i, i+thumbsPerRow).wrapAll("<div class='thumb_row row-" + Math.floor(i/thumbsPerRow + 1) + "' />");
				}

				$(".thumb_row").css("width", (thumbWidth * thumbsPerRow) + "px");

			});

		}

		 $(document).ready(wrapThumbsInRows);

		 // This doesn't work for some reason

		 $(window).resize(wrapThumbsInRows);


// Fake CO2 counter
	
	$(document).ready(function(){
		var numAnim = new countUp("countUp_test", 45978, 46123, 2, 1500);
		numAnim.start();
	});


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
		
		detailExpander.stopPropagation();

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

$(document).ready(function() { // bind to document.ready instead of window.load because of Turbolinks


	// KP's easier version of DRMagicLabelWizzler
	    	$("label").not(".checkbox label").hide().css("right", "-100px");
	    	$("input").bind('click focus touch oninput', function() {
	    		$(this).removeClass("is_valid is_not_valid");
	      		$(this).prev("label").not(".checkbox").fadeIn("fast").css("right", "16px");

				$(this).keyup(function() {
					if ($(this).val().length > 10) {
		          		$(this).prev("label").fadeOut("fast");
	        		} else {
	          			$(this).prev("label").fadeIn("fast");
	        		};
        		});
			});

			$("input.validate").blur(function() {
	      		$(this).prev("label").not(".checkbox").fadeOut("fast");

	      		// this is just to fake validation
				if ($(this).val().length > 2) {
		    		$(this).addClass("is_valid");
		    	} else {
		    		$(this).addClass("is_not_valid");		    		
				};

	    	});


	// System feedback demo for settings page

		$(".show_system_feedback").click(function() {
			$("#system_feedback").removeClass("hide");
		
			// Fadeout element after delay - ie, system feedback notice
			$(".js-auto_fade_away").delay("2000").fadeTo("slow", 0.01, function(){ //fade
			    $(this).slideUp("slow", function() { //slide up
			    	$(this).remove(); //then remove from the DOM
			    });
			});
		});

	// Notification expand demo for dashboard

		$(".js-expand_notification").click(function() {
			$(".js-expand_notification").animate({
				height: "200px"
			}, 250, function() {
			    // Animation complete.
			  });
		});

		$(".dismiss").click(function(){
			$(this).parent().hide();
		});

	// Opaque header & parallax on scroll

    window.onscroll = function() {
	    var yOffset = window.pageYOffset;

		$(".js_scrolling_header").css("backgroundColor", "rgba(32,194,241," + (yOffset * .001) + ")");
		$(".js_scrolling_header").css("borderColor", "rgba(21, 130, 177," + (yOffset * .001) + ")");

		var banner1 = document.getElementById("banner_graphic_br");
    	var banner2 = document.getElementById("first_image_br");
    	var banner3 = document.getElementById("second_image_br");
    	var banner4 = document.getElementById("third_image_br");
	    var speed = 9;

	    var parallax = function(e) {
			e.style.webkitTransform = 'translate3d(0px,' + Math.round(yOffset / speed) + 'px, 0px)';
	    };

	    parallax(banner1);
		parallax(banner2);
		parallax(banner3);
		parallax(banner4);
    };

	jQuery.easing.def = "easeInOutQuart";

    // Fade in scroll leader

    $('.scroll_leader').css('opacity', '0');
    $('.scroll_leader').delay('500').animate({ opacity: 1, bottom: "45px" }, 'slow', 'swing');




    // Just to make sure my syntax is still valid - that's how good I am at this...
	// alert( "welcome" );
});



