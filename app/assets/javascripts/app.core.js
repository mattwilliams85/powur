;
(function() {
  'use strict';

  var references = [
    'ui.router',
    'ngResource',
    'blocks.siren'
  ];

  angular
    .module('app.core', references);
})();