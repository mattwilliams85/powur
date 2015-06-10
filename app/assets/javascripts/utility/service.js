;(function() {
  'use strict';

    function Utility() {
        return {
            searchObjVal: function(object, key) {
              var value = 0;
              findValue(object, key);
              return value;

              function findValue(object, key) {
                if (object.hasOwnProperty(key)) return value = object[key];

                for (var i=0; i < Object.keys(object).length; i++){
                  if (typeof object[Object.keys(object)[i]] == "object"){
                    findValue(object[Object.keys(object)[i]], key);
                  }
                }
                return value;
              }
            }
        }
    }

    Utility.$inject = [];
    angular.module('powurApp').factory('Utility', Utility);
})();
