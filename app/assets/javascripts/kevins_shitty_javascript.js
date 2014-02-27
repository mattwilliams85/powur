$(document).ready(function() { // bind to document.ready instead of window.load because of Turbolinks

	$(".show_system_feedback").click(function() {
		$("#system_feedback").removeClass("hide");
	
		// Fadeout element after delay - ie, system feedback notice
		$(".js-auto_fade_away").delay("2000").fadeTo("slow", 0.01, function(){ //fade
		    $(this).slideUp("slow", function() { //slide up
		    	$(this).remove(); //then remove from the DOM
		    });
		});
	});

});