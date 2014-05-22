# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Opaque header & parallax on scroll

window.onscroll = ->
  yOffset = window.pageYOffset
  $(".js_scrolling_header").css "backgroundColor", "rgba(32,194,241," + (yOffset * .001) + ")"
  $(".js_scrolling_header").css "borderColor", "rgba(21, 130, 177," + (yOffset * .001) + ")"
  banner1 = document.getElementById("banner_graphic_br")
  banner2 = document.getElementById("first_image_br")
  banner3 = document.getElementById("second_image_br")
  banner4 = document.getElementById("third_image_br")
  speed = 9
  parallax = (lax) ->
    lax.style.webkitTransform = "translate3d(0px," + Math.round(yOffset / speed) + "px, 0px)"
    return

  parallax banner1
  parallax banner2
  parallax banner3
  parallax banner4
  return

jQuery.easing.def = "easeInOutQuart"

# Fade in scroll leader
$(".scroll_leader").css "opacity", "0"
$(".scroll_leader").delay("500").animate
  opacity: 1
  bottom: "45px"
, "slow", "swing"
