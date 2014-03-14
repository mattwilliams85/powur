// Show expanded details for dashboard objects


	function detailExpander(showID){
		if($("#" + showID).is(":visible")) {
			$("#" + showID).hide();	
		} else {
			$(".object_detail").hide();
			$("#" + showID).show();
		}
	}


$(document).ready(function() { // bind to document.ready instead of window.load because of Turbolinks


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

	// Parallax scrollingish?

    window.onscroll = function() {
    	var banner = document.getElementById("index_banner");
	    var speed = 1.8;
	    var yOffset = window.pageYOffset;
		banner.style.backgroundPosition = "right "+ (-220 + (-yOffset / speed)) + "px";
    };

    // Just to make sure my syntax is still valid - that's how good I am at this...
	// alert( "welcome" );
});