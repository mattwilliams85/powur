// Show expanded details for dashboard objects


	function detailExpander(showID, btn_text){
		if($("#" + showID).is(":visible")) {
			$("#" + showID).fadeOut("fast");	
			$(".js-" + showID).removeClass("active").html(btn_text);
		} else {
			$("#" + showID).find("form").show();
			$("#" + showID).find(".success").hide();
			$(".object_detail").fadeOut("fast");
			$("#" + showID).show();
			$(".js-" + showID).addClass("active").html("Close");
		}
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

	// Opaque header on scroll

    window.onscroll = function() {
	    var yOffset = window.pageYOffset;

		$(".js_scrolling_header").css("backgroundColor", "rgba(32,194,241," + (yOffset * .001) + ")");
		$(".js_scrolling_header").css("borderColor", "rgba(21, 130, 177," + (yOffset * .001) + ")");

		var banner1 = document.getElementById("banner_graphic_br");
    	var banner2 = document.getElementById("first_image");
    	var banner3 = document.getElementById("second_image");
	    var speed = 9;

		banner1.style.backgroundPosition = "left " + (0 + (yOffset / speed)) + "px";

		banner2.style.backgroundPosition = "center " + (-700 + (yOffset / speed)) + "px";

		banner3.style.backgroundPosition = "center " + (-500 + (yOffset / speed)) + "px";

    };

	jQuery.easing.def = "easeInOutQuart";

    // Fade in scroll leader

    $('.scroll_leader').css('opacity', '0');
    $('.scroll_leader').delay('500').animate({ opacity: 1, bottom: "45px" }, 'slow', 'swing');


	// Parallax scrollingish?


    // Just to make sure my syntax is still valid - that's how good I am at this...
	// alert( "welcome" );
});