;(function() {
  'use strict';

  var references = [
    'widgets.fileS3Uploader',
    'widgets.powurFoundation',
    'widgets.powurLeftMenu',
    'widgets.powurPagePiler',
    'widgets.powurShare'
  ];

  angular
    .module('app.widgets', references);
})();
