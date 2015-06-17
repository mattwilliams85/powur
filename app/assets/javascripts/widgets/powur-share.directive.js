;(function() {
  'use strict';

  function powurShare() {
    function link() {
      function removeTwitter() {
        var $ = function (id) { return document.getElementById(id); };
        var twitter = $('twitter-wjs');
        if (twitter) {
          twitter.remove();
        }
      }

      function initTwitter() {
        removeTwitter();
        window.twttr=(function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],t=window.twttr||{};if(d.getElementById(id))return;js=d.createElement(s);js.id=id;js.src="https://platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);t._e=[];t.ready=function(f){t._e.push(f);};return t;}(document,"script","twitter-wjs"));
      }

      function initFacebook() {
        window.FB=null;
        (function(d, s, id) {
            var js, fjs = d.getElementsByTagName(s)[0];
            js = d.createElement(s); js.id = id;
            js.src = "//connect.facebook.net/en_US/sdk.js#xfbml=1&appId=xxxxxxxxx&version=v2.0";
            fjs.parentNode.insertBefore(js, fjs);
        }(document, 'script', 'facebook-jssdk'));
      }

      initTwitter();
      // initFacebook();
    }

    return {
      restrict: 'E',
      scope: {
        text: '@',
        url: '@'
      },
      templateUrl: 'widgets/powur-share.html',
      link: link
    };
  }

  angular
    .module('widgets.powurShare', [])
    .directive('powurShare', powurShare);

})();
