;
(function() {
  'use strict';

  var references = [
    'ui.router',
    'ui.mask',
    'ngResource',
    'blocks.siren'
  ];

  angular
    .module('app.core', references);
})();
