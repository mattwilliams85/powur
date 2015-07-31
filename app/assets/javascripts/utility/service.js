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
          if (typeof object[Object.keys(object)[i]] === 'object'){
            findValue(object[Object.keys(object)[i]], key);
          }
        }
        return value;
      }
    },
    findBranch: function(obj, keyObj) {
       return findBranchObj(obj, keyObj);
       function findBranchObj(obj, keyObj){
         var p, key, val1, val2, result;
         for (p in keyObj) {
           if (keyObj.hasOwnProperty(p)) {
             key = p;
             val2 = keyObj[p];
           }
         }
         for (p in obj) {
           if (p === key) {
             val1 = obj[p];
             if (Array.isArray(val1)) val1 = val1.join();
             if (val1 === val2) {
               return obj;
             }
           } else if (obj[p] instanceof Object) {
             if (obj.hasOwnProperty(p)) {

               result = findBranchObj(obj[p], keyObj);
               if (result) { return result; }
             }
           }
         }
         return false;
       }
      }
    };
  }

  Utility.$inject = [];
  angular.module('powurApp').factory('Utility', Utility);
})();
