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

      var parallax = function(lax) {
      lax.style.webkitTransform = 'translate3d(0px,' + Math.round(yOffset / speed) + 'px, 0px)';
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

// Fake showing landing forms

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


jQuery(function($){
  $(document).ready(function(){

    //look at the url
    var _code = window.location.search.substring(1).split("=")[0]==="code"? window.location.search.substring(1).split("=")[1]:"";
    if(_code!=="") $(".js-code").val(_code);

    //wire up go button
    $(document).on("click", "form.js-cta_form button", function(e){
      e.preventDefault();
      _code=$(e.target).closest(".js-cta_form").find(".js-code").val();
      _formSubmit(e, $(e.target).closest(".js-cta_form"), "/invite", "post", function(data, text){
        console.log(data);
        if(Object.keys(data).indexOf("links")>=0)
          for(i=0; i<data.links.length;i++)
            if(data.links[i].rel === "new") window.location.replace(data.links[i].href);
      });
    });
  });
});




